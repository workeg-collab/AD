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
  /// Upload native browser File directly to CORS-enabled cloud storage (tmpfiles.org + gofile.io)
  static Future<String?> uploadBrowserFile(html.File file) async {
    // 1. Primary: tmpfiles.org (Instant direct download link, 100% CORS-friendly)
    try {
      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      final completer = Completer<String?>();

      request.open('POST', 'https://tmpfiles.org/api/v1/upload');

      request.onLoad.listen((event) {
        if (request.status == 200) {
          try {
            final data = jsonDecode(request.responseText ?? '');
            final rawUrl = data?['data']?['url'] as String?;
            if (rawUrl != null && rawUrl.contains('tmpfiles.org')) {
              final dlUrl = rawUrl.replaceFirst('tmpfiles.org/', 'tmpfiles.org/dl/');
              completer.complete(dlUrl);
            } else {
              completer.complete(null);
            }
          } catch (_) {
            completer.complete(null);
          }
        } else {
          completer.complete(null);
        }
      });

      request.onError.listen((_) => completer.complete(null));
      request.send(formData);

      final result = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );

      if (result != null && result.startsWith('http')) {
        return result;
      }
    } catch (_) {}

    // 2. Secondary Fallback: Gofile.io (100% CORS-friendly)
    try {
      final srvRes = await http.get(Uri.parse('https://api.gofile.io/servers')).timeout(const Duration(seconds: 8));
      String server = 'store1';
      if (srvRes.statusCode == 200) {
        final srvData = jsonDecode(srvRes.body);
        final servers = srvData?['data']?['servers'] as List?;
        if (servers != null && servers.isNotEmpty) {
          server = servers[0]['name'] ?? 'store1';
        }
      }

      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      final completer = Completer<String?>();

      request.open('POST', 'https://$server.gofile.io/contents/uploadfile');

      request.onLoad.listen((event) {
        if (request.status == 200) {
          try {
            final data = jsonDecode(request.responseText ?? '');
            final pageUrl = data?['data']?['downloadPage'];
            if (pageUrl != null && pageUrl.toString().startsWith('http')) {
              completer.complete(pageUrl.toString());
            } else {
              completer.complete(null);
            }
          } catch (_) {
            completer.complete(null);
          }
        } else {
          completer.complete(null);
        }
      });

      request.onError.listen((_) => completer.complete(null));
      request.send(formData);

      return await completer.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () => null,
      );
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

        input.onChange.listen((event) async {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            try {
              final fileUrl = await uploadBrowserFile(file);
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
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
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

        input.onChange.listen((event) async {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final List<UploadedFileResult> results = [];
            for (final file in files) {
              try {
                final fileUrl = await uploadBrowserFile(file);
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
        return result.files.map((f) => UploadedFileResult(fileName: f.name)).toList();
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
              final fileUrl = await uploadBrowserFile(file);
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
        return UploadedFileResult(fileName: file.name);
      }
    } catch (_) {}

    return null;
  }
}
