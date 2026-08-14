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
  /// Upload image directly to Freeimage.host (CORS-friendly, global CDN, permanent link)
  static Future<String?> uploadImageDirect(String base64Data) async {
    try {
      final response = await http.post(
        Uri.parse('https://freeimage.host/api/1/upload'),
        body: {
          'key': '6d207e02198a847aa98d0a2a901485a5',
          'action': 'upload',
          'source': base64Data,
          'format': 'json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data?['image']?['url'] ?? data?['image']?['display_url'];
        if (url != null && url.toString().startsWith('http')) {
          return url.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upload document (PDF, Word, etc.) to Gofile.io (CORS-friendly, global download page)
  static Future<String?> uploadDocumentDirect(html.File file) async {
    try {
      // 1. Fetch available server
      final srvRes = await http.get(Uri.parse('https://api.gofile.io/servers')).timeout(const Duration(seconds: 8));
      String server = 'store1';
      if (srvRes.statusCode == 200) {
        final srvData = jsonDecode(srvRes.body);
        final servers = srvData?['data']?['servers'] as List?;
        if (servers != null && servers.isNotEmpty) {
          server = servers[0]['name'] ?? 'store1';
        }
      }

      // 2. Upload via native browser HttpRequest
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

      return await completer.future.timeout(const Duration(seconds: 25), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  /// Upload base64 fallback via /api/upload
  static Future<String?> uploadViaBackend({
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['fileUrl'] != null && data['fileUrl'].toString().startsWith('http')) {
          return data['fileUrl'] as String;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Pick and upload a single image (Logo)
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

                // 1. Try Freeimage.host direct client upload
                String? fileUrl = await uploadImageDirect(base64String);

                // 2. Fallback to /api/upload
                fileUrl ??= await uploadViaBackend(
                  base64Data: base64String,
                  fileName: file.name,
                  mimeType: file.type.isNotEmpty ? file.type : 'image/png',
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
          String? fileUrl = await uploadImageDirect(base64String);
          fileUrl ??= await uploadViaBackend(
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

                  String? fileUrl = await uploadImageDirect(base64String);
                  fileUrl ??= await uploadViaBackend(
                    base64Data: base64String,
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
            final base64String = base64Encode(file.bytes!);
            String? fileUrl = await uploadImageDirect(base64String);
            fileUrl ??= await uploadViaBackend(
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

            // First try direct document upload via Gofile
            uploadDocumentDirect(file).then((fileUrl) async {
              if (fileUrl != null && fileUrl.startsWith('http')) {
                completer.complete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } else {
                // Fallback to base64 upload via backend
                final reader = html.FileReader();
                reader.readAsDataUrl(file);
                reader.onLoadEnd.listen((e) async {
                  try {
                    final dataUrl = reader.result as String;
                    final base64String = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
                    final backendUrl = await uploadViaBackend(
                      base64Data: base64String,
                      fileName: file.name,
                      mimeType: file.type.isNotEmpty ? file.type : 'application/pdf',
                    );
                    completer.complete(UploadedFileResult(fileName: file.name, fileUrl: backendUrl));
                  } catch (_) {
                    completer.complete(UploadedFileResult(fileName: file.name));
                  }
                });
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
          final fileUrl = await uploadViaBackend(
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
