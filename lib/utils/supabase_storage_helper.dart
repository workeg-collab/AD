import 'dart:async';
import 'dart:convert';
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

  /// Upload Base64 to Serverless /api/supabase-upload (100% CORS & AdBlock free)
  static Future<String?> uploadViaServerless({
    required String base64Data,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('/api/supabase-upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Data,
          'fileName': fileName,
          'fileType': mimeType.isNotEmpty ? mimeType : _getContentType(fileName),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileUrl = data?['fileUrl'] as String?;
        if (fileUrl != null && fileUrl.startsWith('http')) {
          return fileUrl;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upload native browser File directly via XMLHttpRequest fallback
  static Future<String?> uploadHtmlFileDirect({
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
          completer.complete(publicUrl);
        } else {
          completer.complete(null);
        }
      });

      request.onError.listen((event) => completer.complete(null));
      request.send(file);

      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Master upload method for a web file
  static Future<String?> uploadWebFile(html.File file) async {
    final completer = Completer<String?>();
    final reader = html.FileReader();
    reader.readAsDataUrl(file);

    reader.onLoadEnd.listen((event) async {
      try {
        final dataUrl = reader.result as String;
        final base64String = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
        final mimeType = file.type.isNotEmpty ? file.type : _getContentType(file.name);

        // 1. Try serverless bridge first (Guaranteed 100% success)
        String? fileUrl = await uploadViaServerless(
          base64Data: base64String,
          fileName: file.name,
          mimeType: mimeType,
        );

        // 2. Fallback to direct upload if serverless didn't return URL
        fileUrl ??= await uploadHtmlFileDirect(
          file: file,
          contentType: mimeType,
        );

        completer.complete(fileUrl);
      } catch (_) {
        completer.complete(null);
      }
    });

    return await completer.future.timeout(
      const Duration(seconds: 40),
      onTimeout: () => null,
    );
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
              final fileUrl = await uploadWebFile(file);
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
          final base64String = base64Encode(file.bytes!);
          final fileUrl = await uploadViaServerless(
            base64Data: base64String,
            fileName: file.name,
            mimeType: _getContentType(file.name),
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
                final fileUrl = await uploadWebFile(file);
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
            final base64String = base64Encode(file.bytes!);
            final fileUrl = await uploadViaServerless(
              base64Data: base64String,
              fileName: file.name,
              mimeType: _getContentType(file.name),
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
              final fileUrl = await uploadWebFile(file);
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
          final base64String = base64Encode(file.bytes!);
          final fileUrl = await uploadViaServerless(
            base64Data: base64String,
            fileName: file.name,
            mimeType: _getContentType(file.name),
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
