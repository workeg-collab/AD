import 'dart:async';
import 'dart:convert';
import 'dart:math';
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

  /// Read an html.File as a Base64 data URL string reliably
  static Future<String?> _readHtmlFileAsDataUrl(html.File file) {
    final completer = Completer<String?>();
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      if (reader.result != null) {
        completer.complete(reader.result.toString());
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((event) {
      completer.complete(null);
    });
    reader.readAsDataUrl(file);
    return completer.future.timeout(const Duration(seconds: 40), onTimeout: () => null);
  }

  /// Upload file to Supabase via the reliable Serverless Bridge (/api/supabase-upload)
  static Future<String?> _uploadViaServerlessBridge(String base64Data, String fileName, String fileType) async {
    try {
      final response = await http
          .post(
            Uri.parse('/api/supabase-upload'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'base64Data': base64Data,
              'fileName': fileName,
              'fileType': fileType,
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['fileUrl'] != null) {
          final url = data['fileUrl'] as String;
          debugPrint('✅ Upload via /api/supabase-upload SUCCESS: $url');
          return url;
        }
      }
      debugPrint('❌ Bridge status ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('❌ Bridge upload error: $e');
    }
    return null;
  }

  /// Upload raw bytes directly to Supabase Storage endpoint (Universal fallback)
  static Future<String?> uploadBytesDirect(Uint8List bytes, String originalFileName, {String? mimeType}) async {
    final contentType = (mimeType != null && mimeType.isNotEmpty)
        ? mimeType
        : _getContentType(originalFileName);

    // 1. Try Vercel Serverless Bridge if on Web
    if (kIsWeb) {
      try {
        final base64String = base64Encode(bytes);
        final bridgeUrl = await _uploadViaServerlessBridge(base64String, originalFileName, contentType);
        if (bridgeUrl != null && bridgeUrl.isNotEmpty) {
          return bridgeUrl;
        }
      } catch (_) {}
    }

    // 2. Direct Supabase Storage API call
    try {
      final uniquePath = _generateUniquePath(originalFileName);
      final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$uniquePath');
      final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';

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
    return null;
  }

  /// Upload browser native File directly with guaranteed fallback
  static Future<String?> uploadHtmlFileDirect(html.File file) async {
    final contentType = file.type.isNotEmpty ? file.type : _getContentType(file.name);

    // 1. Read file as Base64 Data URL (Highest reliability across all browsers & zero CORS issues)
    try {
      final dataUrl = await _readHtmlFileAsDataUrl(file);
      if (dataUrl != null && dataUrl.isNotEmpty) {
        final bridgeUrl = await _uploadViaServerlessBridge(dataUrl, file.name, contentType);
        if (bridgeUrl != null && bridgeUrl.isNotEmpty) {
          return bridgeUrl;
        }
      }
    } catch (e) {
      debugPrint('Error reading file as data URL: $e');
    }

    // 2. Direct Supabase Storage API fallback
    try {
      final uniquePath = _generateUniquePath(file.name);
      final uploadUri = '$supabaseUrl/storage/v1/object/$bucketName/$uniquePath';
      final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';

      final completer = Completer<String?>();
      final request = html.HttpRequest();
      request.open('POST', uploadUri, async: true);
      request.setRequestHeader('apikey', supabaseAnonKey);
      request.setRequestHeader('Authorization', 'Bearer $supabaseAnonKey');
      request.setRequestHeader('Content-Type', contentType);

      request.onLoad.listen((event) {
        if (request.status == 200 || request.status == 201) {
          debugPrint('✅ Supabase Direct Upload SUCCESS: $publicUrl');
          completer.complete(publicUrl);
        } else {
          debugPrint('❌ Supabase Direct Upload Failed: ${request.status}');
          completer.complete(null);
        }
      });

      request.onError.listen((event) => completer.complete(null));
      request.send(file);

      final directUrl = await completer.future.timeout(const Duration(seconds: 40), onTimeout: () => null);
      if (directUrl != null) return directUrl;
    } catch (e) {
      debugPrint('Direct upload exception: $e');
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
