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

class WebFilePicker {
  /// Upload base64 data to /api/upload
  static Future<String?> uploadBase64({
    required String base64Data,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('/api/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Data,
          'fileName': fileName,
          'fileType': mimeType,
        }),
      ).timeout(const Duration(seconds: 25));

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

  /// Pick and upload a single file (Logo)
  static Future<UploadedFileResult?> pickAndUploadSingleImage({
    String accept = 'image/*',
    List<String>? allowedExtensions,
  }) async {
    if (kIsWeb) {
      try {
        final completer = Completer<UploadedFileResult?>();
        final input = html.FileUploadInputElement()
          ..accept = accept
          ..multiple = false;

        input.click();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            final reader = html.FileReader();
            reader.readAsDataUrl(file);
            reader.onLoadEnd.listen((e) async {
              try {
                final dataUrl = reader.result as String;
                final base64String = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
                final mimeType = file.type.isNotEmpty ? file.type : 'image/png';

                final fileUrl = await uploadBase64(
                  base64Data: base64String,
                  fileName: file.name,
                  mimeType: mimeType,
                );

                completer.complete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                completer.complete(UploadedFileResult(fileName: file.name));
              }
            });
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
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final base64String = base64Encode(file.bytes!);
          final fileUrl = await uploadBase64(
            base64Data: base64String,
            fileName: file.name,
            mimeType: 'image/png',
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }

  /// Pick and upload multiple images (Activity / Product Photos)
  static Future<List<UploadedFileResult>> pickAndUploadMultipleImages() async {
    if (kIsWeb) {
      try {
        final completer = Completer<List<UploadedFileResult>>();
        final input = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = true;

        input.click();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final List<UploadedFileResult> results = [];
            int processed = 0;

            for (final file in files) {
              final reader = html.FileReader();
              reader.readAsDataUrl(file);
              reader.onLoadEnd.listen((e) async {
                try {
                  final dataUrl = reader.result as String;
                  final base64String = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
                  final mimeType = file.type.isNotEmpty ? file.type : 'image/jpeg';

                  final fileUrl = await uploadBase64(
                    base64Data: base64String,
                    fileName: file.name,
                    mimeType: mimeType,
                  );

                  results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
                } catch (_) {
                  results.add(UploadedFileResult(fileName: file.name));
                }

                processed++;
                if (processed == files.length) {
                  completer.complete(results);
                }
              });
            }
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
            final base64String = base64Encode(file.bytes!);
            final fileUrl = await uploadBase64(
              base64Data: base64String,
              fileName: file.name,
              mimeType: 'image/jpeg',
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

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            final reader = html.FileReader();
            reader.readAsDataUrl(file);
            reader.onLoadEnd.listen((e) async {
              try {
                final dataUrl = reader.result as String;
                final base64String = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
                final mimeType = file.type.isNotEmpty ? file.type : 'application/pdf';

                final fileUrl = await uploadBase64(
                  base64Data: base64String,
                  fileName: file.name,
                  mimeType: mimeType,
                );

                completer.complete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                completer.complete(UploadedFileResult(fileName: file.name));
              }
            });
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
          final base64String = base64Encode(file.bytes!);
          final fileUrl = await uploadBase64(
            base64Data: base64String,
            fileName: file.name,
            mimeType: 'application/pdf',
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }
}
