import 'dart:async';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

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

  /// Stream native browser File directly to Supabase Storage via XMLHttpRequest
  static Future<String?> uploadHtmlFileDirect(html.File file) {
    final completer = Completer<String?>();
    final cleanFileName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
    final uploadUri = '$supabaseUrl/storage/v1/object/$bucketName/$uniquePath';
    final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';

    final request = html.HttpRequest();
    request.open('POST', uploadUri, async: true);
    request.setRequestHeader('apikey', supabaseAnonKey);
    request.setRequestHeader('Authorization', 'Bearer $supabaseAnonKey');
    request.setRequestHeader(
      'Content-Type',
      file.type.isNotEmpty ? file.type : _getContentType(file.name),
    );

    request.onLoad.listen((event) {
      if (request.status == 200 || request.status == 201) {
        debugPrint('✅ Supabase Upload SUCCESS: $publicUrl');
        completer.complete(publicUrl);
      } else {
        debugPrint('❌ Supabase Upload Status: ${request.status} - ${request.responseText}');
        completer.complete(null);
      }
    });

    request.onError.listen((event) {
      debugPrint('❌ Supabase Network Error');
      completer.complete(null);
    });

    request.send(file);
    return completer.future.timeout(const Duration(seconds: 40), onTimeout: () => null);
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

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);
            try {
              final fileUrl = await uploadHtmlFileDirect(file);
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name));
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
        debugPrint('Web sync pick logo error: $err');
      }
    }

    // Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.image, withData: true).then((result) {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onComplete(UploadedFileResult(fileName: file.name));
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

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            onUploadStatusChanged(true);
            final List<UploadedFileResult> results = [];
            for (final file in files) {
              try {
                final fileUrl = await uploadHtmlFileDirect(file);
                results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } catch (_) {
                results.add(UploadedFileResult(fileName: file.name));
              }
            }
            onUploadStatusChanged(false);
            uploadInput.remove();
            onComplete(results);
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

    // Non-web fallback
    FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, withData: true).then((result) {
      if (result != null && result.files.isNotEmpty) {
        final List<UploadedFileResult> results = result.files
            .map((f) => UploadedFileResult(fileName: f.name))
            .toList();
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

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            onUploadStatusChanged(true);
            try {
              final fileUrl = await uploadHtmlFileDirect(file);
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name));
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
        debugPrint('Web sync pick doc error: $err');
      }
    }

    // Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.any, withData: true).then((result) {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onComplete(UploadedFileResult(fileName: file.name));
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
