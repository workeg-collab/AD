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
  /// Upload file bytes to cloud storage and return permanent direct URL
  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    // 1. Try /api/upload
    try {
      final base64String = base64Encode(bytes);
      final response = await http.post(
        Uri.parse('/api/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64String,
          'fileName': fileName,
          'fileType': mimeType,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['fileUrl'] != null) {
          return data['fileUrl'] as String;
        }
      }
    } catch (_) {}

    // 2. Direct fallback to Catbox.moe API (worldwide permanent free file hosting)
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://catbox.moe/user/api.php'),
      );
      request.fields['reqtype'] = 'fileupload';
      request.files.add(
        http.MultipartFile.fromBytes(
          'fileToUpload',
          bytes,
          filename: fileName,
        ),
      );
      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);
      final text = response.body.trim();
      if (text.startsWith('http://') || text.startsWith('https://')) {
        return text;
      }
    } catch (_) {}

    return null;
  }

  /// Pick and upload a single file (e.g. Logo)
  static Future<UploadedFileResult?> pickAndUploadSingleFile({
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
            reader.readAsArrayBuffer(file);
            reader.onLoadEnd.listen((e) async {
              try {
                final bytes = Uint8List.fromList(reader.result as List<int>);
                final fileUrl = await uploadBytes(
                  bytes: bytes,
                  fileName: file.name,
                  mimeType: file.type.isNotEmpty ? file.type : 'application/octet-stream',
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
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            mimeType: 'application/octet-stream',
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }

  /// Pick and upload multiple images (e.g. Activity / Product Photos)
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
              reader.readAsArrayBuffer(file);
              reader.onLoadEnd.listen((e) async {
                try {
                  final bytes = Uint8List.fromList(reader.result as List<int>);
                  final fileUrl = await uploadBytes(
                    bytes: bytes,
                    fileName: file.name,
                    mimeType: file.type.isNotEmpty ? file.type : 'image/jpeg',
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
            final fileUrl = await uploadBytes(
              bytes: file.bytes!,
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
    return await pickAndUploadSingleFile(
      accept: '.pdf,.doc,.docx,.ppt,.pptx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
  }
}
