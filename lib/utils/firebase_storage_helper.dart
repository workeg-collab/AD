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

class FirebaseStorageHelper {
  static const String storageBucket = 'sa-pom.firebasestorage.app';
  static const String altBucket = 'sa-pom.appspot.com';

  /// Upload binary file to Firebase Storage via REST API and return direct public download URL
  static Future<String?> uploadBytesToFirebase({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniquePath = 'orders/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    // Try primary bucket, then alternative bucket
    final buckets = [storageBucket, altBucket];

    for (final bucket in buckets) {
      try {
        final uploadUrl = Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/$bucket/o?uploadType=media&name=${Uri.encodeComponent(uniquePath)}',
        );

        final response = await http.post(
          uploadUrl,
          headers: {
            'Content-Type': contentType.isNotEmpty ? contentType : 'application/octet-stream',
          },
          body: bytes,
        ).timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final name = data['name'] as String?;
          final token = data['downloadTokens'] as String?;

          if (name != null) {
            final directUrl =
                'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(name)}?alt=media${token != null && token.isNotEmpty ? "&token=$token" : ""}';
            return directUrl;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Pick and upload a single image (Logo) to Firebase Storage
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

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files.first;
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            reader.onLoadEnd.listen((e) async {
              try {
                final bytes = (reader.result as ByteBuffer).asUint8List();
                final fileUrl = await uploadBytesToFirebase(
                  bytes: bytes,
                  fileName: file.name,
                  contentType: file.type.isNotEmpty ? file.type : 'image/png',
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
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final fileUrl = await uploadBytesToFirebase(
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

  /// Pick and upload multiple images (Activity / Product Photos) to Firebase Storage
  static Future<List<UploadedFileResult>> pickAndUploadPhotos() async {
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
                  final bytes = (reader.result as ByteBuffer).asUint8List();
                  final fileUrl = await uploadBytesToFirebase(
                    bytes: bytes,
                    fileName: file.name,
                    contentType: file.type.isNotEmpty ? file.type : 'image/jpeg',
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
            final fileUrl = await uploadBytesToFirebase(
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

  /// Pick and upload company profile document (PDF, Word, PPT) to Firebase Storage
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
            reader.readAsArrayBuffer(file);
            reader.onLoadEnd.listen((e) async {
              try {
                final bytes = (reader.result as ByteBuffer).asUint8List();
                final fileUrl = await uploadBytesToFirebase(
                  bytes: bytes,
                  fileName: file.name,
                  contentType: file.type.isNotEmpty ? file.type : 'application/pdf',
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
          final fileUrl = await uploadBytesToFirebase(
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
