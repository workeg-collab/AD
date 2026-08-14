import 'dart:async';
import 'dart:convert';
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

  static Uint8List _toUint8List(dynamic raw) {
    if (raw is Uint8List) return raw;
    if (raw is ByteBuffer) return raw.asUint8List();
    if (raw is List<int>) return Uint8List.fromList(raw);
    try {
      final buffer = (raw as dynamic).buffer;
      if (buffer is ByteBuffer) {
        return buffer.asUint8List();
      }
    } catch (_) {}
    return Uint8List.view(raw as dynamic);
  }

  /// Upload raw binary file bytes (Uint8List) directly to Supabase Storage
  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    // 1. Direct binary HTTP upload to Supabase Storage REST API
    try {
      final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$uniquePath');

      final response = await http.post(
        uploadUri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': contentType.isNotEmpty ? contentType : 'application/octet-stream',
        },
        body: bytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';
        debugPrint('✅ Direct Supabase Upload Success: $publicUrl');
        return publicUrl;
      }
    } catch (e) {
      debugPrint('⚠️ Direct Supabase upload error: $e');
    }

    // 2. Serverless API bridge fallback with Base64 payload
    try {
      final base64Data = base64Encode(bytes);
      final response = await http.post(
        Uri.parse('/api/supabase-upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Data,
          'fileName': fileName,
          'fileType': contentType,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileUrl = data?['fileUrl'] as String?;
        if (fileUrl != null && fileUrl.startsWith('http')) {
          debugPrint('✅ Serverless Supabase Upload Success: $fileUrl');
          return fileUrl;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Serverless Supabase upload error: $e');
    }

    return null;
  }

  /// Pick Logo synchronously on Web to satisfy browser user-activation security
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

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);

            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);

            reader.onLoadEnd.listen((event) async {
              try {
                final bytes = _toUint8List(reader.result);
                final fileUrl = await uploadBytes(
                  bytes: bytes,
                  fileName: file.name,
                  contentType: file.type.isNotEmpty ? file.type : _getContentType(file.name),
                );

                onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                onComplete(UploadedFileResult(fileName: file.name));
              } finally {
                onUploadStatusChanged(false);
                uploadInput.remove();
              }
            });
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web sync pick logo error: $err');
      }
    }

    // Fallback for non-web
    FilePicker.platform.pickFiles(type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        }
      }
    });
  }

  /// Pick Photos synchronously on Web
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

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            onUploadStatusChanged(true);
            final List<UploadedFileResult> results = [];
            int processed = 0;

            for (final file in files) {
              final reader = html.FileReader();
              reader.readAsArrayBuffer(file);

              reader.onLoadEnd.listen((event) async {
                try {
                  final bytes = _toUint8List(reader.result);
                  final fileUrl = await uploadBytes(
                    bytes: bytes,
                    fileName: file.name,
                    contentType: file.type.isNotEmpty ? file.type : _getContentType(file.name),
                  );

                  results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
                } catch (_) {
                  results.add(UploadedFileResult(fileName: file.name));
                }

                processed++;
                if (processed == files.length) {
                  onUploadStatusChanged(false);
                  uploadInput.remove();
                  onComplete(results);
                }
              });
            }
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web sync pick photos error: $err');
      }
    }

    // Fallback for non-web
    FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        onUploadStatusChanged(true);
        final List<UploadedFileResult> results = [];
        for (final file in result.files) {
          if (file.bytes != null) {
            final fileUrl = await uploadBytes(
              bytes: file.bytes!,
              fileName: file.name,
              contentType: _getContentType(file.name),
            );
            results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
          }
        }
        onUploadStatusChanged(false);
        onComplete(results);
      }
    });
  }

  /// Pick Profile Document synchronously on Web
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

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);

            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);

            reader.onLoadEnd.listen((event) async {
              try {
                final bytes = _toUint8List(reader.result);
                final fileUrl = await uploadBytes(
                  bytes: bytes,
                  fileName: file.name,
                  contentType: file.type.isNotEmpty ? file.type : _getContentType(file.name),
                );

                onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                onComplete(UploadedFileResult(fileName: file.name));
              } finally {
                onUploadStatusChanged(false);
                uploadInput.remove();
              }
            });
          } else {
            uploadInput.remove();
          }
        });

        uploadInput.click();
        return;
      } catch (err) {
        debugPrint('Web sync pick doc error: $err');
      }
    }

    // Fallback for non-web
    FilePicker.platform.pickFiles(type: FileType.any, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        }
      }
    });
  }

  static String _getContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
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
