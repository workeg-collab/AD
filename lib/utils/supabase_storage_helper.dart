import 'dart:async';
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

  /// Upload native browser File directly via XMLHttpRequest with 100% accuracy
  static Future<String?> uploadHtmlFile({
    required html.File file,
    required String contentType,
  }) async {
    try {
      final cleanFileName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
      final uploadUri = '$supabaseUrl/storage/v1/object/$bucketName/$uniquePath';
      final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';

      final completer = Completer<String?>();
      final request = html.HttpRequest();

      request.open('POST', uploadUri, async: true);
      request.setRequestHeader('apikey', supabaseAnonKey);
      request.setRequestHeader('Authorization', 'Bearer $supabaseAnonKey');
      request.setRequestHeader(
        'Content-Type',
        contentType.isNotEmpty ? contentType : _getContentType(file.name),
      );

      request.onLoad.listen((event) {
        if (request.status == 200 || request.status == 201) {
          debugPrint('✅ Supabase Upload SUCCESS: $publicUrl');
          completer.complete(publicUrl);
        } else {
          debugPrint('❌ Supabase Upload FAILED [${request.status}]: ${request.responseText}');
          completer.complete(null);
        }
      });

      request.onError.listen((event) {
        debugPrint('❌ Supabase Upload Network Error');
        completer.complete(null);
      });

      request.send(file);

      return await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          debugPrint('❌ Supabase Upload Timeout');
          return null;
        },
      );
    } catch (e) {
      debugPrint('❌ Supabase Upload Exception: $e');
      return null;
    }
  }

  /// Upload raw bytes fallback (for non-web platforms)
  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    try {
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
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
        return publicUrl;
      }
    } catch (_) {}
    return null;
  }

  /// Pick and upload a single image (Logo)
  static Future<UploadedFileResult?> pickAndUploadLogo({
    String accept = 'image/*',
  }) async {
    if (kIsWeb) {
      try {
        final completer = Completer<UploadedFileResult?>();
        final input = html.FileUploadInputElement()
          ..accept = accept
          ..multiple = false
          ..style.display = 'none';

        html.document.body?.children.add(input);
        input.click();

        input.onChange.listen((event) async {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            try {
              final fileUrl = await uploadHtmlFile(
                file: file,
                contentType: file.type.isNotEmpty ? file.type : 'image/png',
              );
              completer.complete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              completer.complete(UploadedFileResult(fileName: file.name));
            } finally {
              input.remove();
            }
          } else {
            input.remove();
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            input.remove();
            return null;
          },
        );
      } catch (_) {}
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }

  /// Pick and upload multiple images (Activity / Product Photos)
  static Future<List<UploadedFileResult>> pickAndUploadPhotos() async {
    if (kIsWeb) {
      try {
        final completer = Completer<List<UploadedFileResult>>();
        final input = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = true
          ..style.display = 'none';

        html.document.body?.children.add(input);
        input.click();

        input.onChange.listen((event) async {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final List<UploadedFileResult> results = [];
            for (final file in files) {
              try {
                final fileUrl = await uploadHtmlFile(
                  file: file,
                  contentType: file.type.isNotEmpty ? file.type : 'image/jpeg',
                );
                results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                results.add(UploadedFileResult(fileName: file.name));
              }
            }
            input.remove();
            completer.complete(results);
          } else {
            input.remove();
            completer.complete([]);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            input.remove();
            return [];
          },
        );
      } catch (_) {}
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final List<UploadedFileResult> results = [];
        for (final file in result.files) {
          if (file.bytes != null) {
            final fileUrl = await uploadBytes(
              bytes: file.bytes!,
              fileName: file.name,
              contentType: _getContentType(file.name),
            );
            results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
          } else {
            results.add(UploadedFileResult(fileName: file.name));
          }
        }
        return results;
      }
    } catch (_) {}

    return [];
  }

  /// Pick and upload company profile document (PDF, Word, PPT)
  static Future<UploadedFileResult?> pickAndUploadProfileDocument() async {
    if (kIsWeb) {
      try {
        final completer = Completer<UploadedFileResult?>();
        final input = html.FileUploadInputElement()
          ..accept = '.pdf,.doc,.docx,.ppt,.pptx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..multiple = false
          ..style.display = 'none';

        html.document.body?.children.add(input);
        input.click();

        input.onChange.listen((event) async {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            try {
              final fileUrl = await uploadHtmlFile(
                file: file,
                contentType: file.type.isNotEmpty ? file.type : 'application/pdf',
              );
              completer.complete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              completer.complete(UploadedFileResult(fileName: file.name));
            } finally {
              input.remove();
            }
          } else {
            input.remove();
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            input.remove();
            return null;
          },
        );
      } catch (_) {}
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
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
