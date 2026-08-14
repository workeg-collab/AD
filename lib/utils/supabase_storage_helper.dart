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

  /// Upload native browser File directly to Supabase Storage
  static Future<String?> uploadHtmlFile({
    required html.File file,
    required String contentType,
  }) async {
    try {
      final cleanFileName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
      final uploadUri = '$supabaseUrl/storage/v1/object/$bucketName/$uniquePath';

      final request = html.HttpRequest();
      final completer = Completer<String?>();

      request.open('POST', uploadUri);
      request.setRequestHeader('apikey', supabaseAnonKey);
      request.setRequestHeader('Authorization', 'Bearer $supabaseAnonKey');
      request.setRequestHeader(
        'Content-Type',
        contentType.isNotEmpty ? contentType : 'application/octet-stream',
      );

      request.onLoad.listen((event) {
        if (request.status == 200 || request.status == 201) {
          final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';
          completer.complete(publicUrl);
        } else {
          completer.complete(null);
        }
      });

      request.onError.listen((_) => completer.complete(null));
      request.send(file);

      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Upload bytes fallback via http package
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
      ).timeout(const Duration(seconds: 25));

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
          ..multiple = false;

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
            }
          } else {
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => null,
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
            contentType: 'image/png',
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
          ..multiple = true;

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
            completer.complete(results);
          } else {
            completer.complete([]);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => [],
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
              contentType: 'image/jpeg',
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
          ..multiple = false;

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
            }
          } else {
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => null,
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
            contentType: 'application/pdf',
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }
}
