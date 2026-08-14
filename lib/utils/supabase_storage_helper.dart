import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadedFileResult {
  final String fileName;
  final String? fileUrl;

  UploadedFileResult({required this.fileName, this.fileUrl});

  @override
  String toString() => fileUrl != null ? fileUrl! : fileName;
}

class SupabaseStorageHelper {
  // Supabase Project Credentials
  static const String supabaseUrl = 'https://spvlwhdtpnfuenwrfayv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwdmx3aGR0cG5mdWVud3JmYXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY3MTgwNjMsImV4cCI6MjEwMjI5NDA2M30.1jc8ahuejtrfIRMTOFO-aVYMwOd7einjtUQdou2kNBY';
  static const String bucketName = 'orders';

  /// Generates a unique, URL-safe filename while preserving the original extension.
  static String _generateUniquePath(String originalFileName) {
    String ext = '';
    final dotIndex = originalFileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < originalFileName.length - 1) {
      ext = originalFileName.substring(dotIndex).toLowerCase();
      ext = ext.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '');
    }

    final safeBase = originalFileName
        .split('.')
        .first
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final shortBase = safeBase.length > 20 ? safeBase.substring(0, 20) : (safeBase.isEmpty ? 'file' : safeBase);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(900000) + 100000;

    return '${timestamp}_${randomSuffix}_$shortBase$ext';
  }

  /// Read an html.File as Uint8List safely without type casting issues
  static Future<Uint8List?> _readFileBytes(html.File file) {
    final completer = Completer<Uint8List?>();
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      if (reader.result != null) {
        try {
          final dynamic result = reader.result;
          if (result is Uint8List) {
            completer.complete(result);
          } else if (result is ByteBuffer) {
            completer.complete(result.asUint8List());
          } else if (result is List<int>) {
            completer.complete(Uint8List.fromList(result));
          } else {
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('Error converting file bytes: $e');
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((event) => completer.complete(null));
    reader.readAsArrayBuffer(file);
    return completer.future.timeout(const Duration(seconds: 40), onTimeout: () => null);
  }

  /// Upload raw bytes directly to Supabase Storage endpoint (Primary) with Serverless Fallback
  static Future<String?> uploadBytesDirect(Uint8List bytes, String originalFileName, {String? mimeType}) async {
    final uniquePath = _generateUniquePath(originalFileName);
    final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$uniquePath');
    final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';
    final contentType = (mimeType != null && mimeType.isNotEmpty)
        ? mimeType
        : _getContentType(originalFileName);

    // 1. Direct Supabase Storage Upload via HTTP POST (Handles up to 50MB)
    try {
      final response = await http
          .post(
            uploadUri,
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': contentType,
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Supabase Direct Bytes Upload SUCCESS: $publicUrl');
        return publicUrl;
      }
      debugPrint('❌ Supabase Direct Bytes Status ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('❌ Supabase Direct Bytes Exception: $e');
    }

    // 2. Fallback to Serverless Bridge on Web
    if (kIsWeb) {
      try {
        final base64String = base64Encode(bytes);
        final bridgeUri = Uri.base.resolve('/api/supabase-upload');
        final response = await http
            .post(
              bridgeUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'base64Data': base64String,
                'fileName': originalFileName,
                'fileType': contentType,
              }),
            )
            .timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['fileUrl'] != null) {
            final url = data['fileUrl'] as String;
            debugPrint('✅ Serverless Bridge Upload SUCCESS: $url');
            return url;
          }
        }
        debugPrint('❌ Bridge status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('❌ Bridge upload error: $e');
      }
    }

    return null;
  }

  /// Upload browser native File directly with guaranteed bytes streaming
  static Future<String?> uploadHtmlFileDirect(html.File file) async {
    try {
      final bytes = await _readFileBytes(file);
      if (bytes != null && bytes.isNotEmpty) {
        final mime = file.type.isNotEmpty ? file.type : _getContentType(file.name);
        return await uploadBytesDirect(bytes, file.name, mimeType: mime);
      }
    } catch (e) {
      debugPrint('uploadHtmlFileDirect error: $e');
    }
    return null;
  }

  /// Pick Logo synchronously on Web & Native
  static void pickLogo({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(UploadedFileResult result) onComplete,
  }) {
    if (kIsWeb) {
      try {
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = false
          ..style.display = 'none';

        html.document.body?.children.add(uploadInput);

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);
            try {
              final fileUrl = await uploadHtmlFileDirect(file);
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
            } finally {
              onUploadStatusChanged(false);
              uploadInput.remove();
            }
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web pick logo error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        } else {
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
        }
      }
    });
  }

  /// Pick Photos synchronously on Web & Native (concurrent uploads)
  static void pickPhotos({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(List<UploadedFileResult> results) onComplete,
  }) {
    if (kIsWeb) {
      try {
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = true
          ..style.display = 'none';

        html.document.body?.children.add(uploadInput);

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            onUploadStatusChanged(true);
            try {
              final uploadTasks = files.map((file) async {
                final fileUrl = await uploadHtmlFileDirect(file);
                return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
              }).toList();

              final results = await Future.wait(uploadTasks);
              onComplete(results);
            } catch (err) {
              debugPrint('Error uploading photos: $err');
              onComplete([]);
            } finally {
              onUploadStatusChanged(false);
              uploadInput.remove();
            }
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web pick photos error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        onUploadStatusChanged(true);
        try {
          final uploadTasks = result.files.map((file) async {
            if (file.bytes != null) {
              final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
              return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
            }
            return UploadedFileResult(fileName: file.name, fileUrl: null);
          }).toList();

          final results = await Future.wait(uploadTasks);
          onComplete(results);
        } catch (_) {
          onComplete([]);
        } finally {
          onUploadStatusChanged(false);
        }
      }
    });
  }

  /// Pick Profile Document synchronously on Web & Native
  static void pickProfileDocument({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(UploadedFileResult result) onComplete,
  }) {
    if (kIsWeb) {
      try {
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
          ..accept = '.pdf,.doc,.docx,.ppt,.pptx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..multiple = false
          ..style.display = 'none';

        html.document.body?.children.add(uploadInput);

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);
            try {
              final fileUrl = await uploadHtmlFileDirect(file);
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
            } finally {
              onUploadStatusChanged(false);
              uploadInput.remove();
            }
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web pick profile error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.any, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        } else {
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
        }
      }
    });
  }

  static String _getContentType(String filename) {
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'svg':
        return 'image/svg+xml';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }
}
