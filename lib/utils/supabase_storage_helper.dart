import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Ensure Supabase client is initialized
  static Future<void> ensureInitialized() async {
    try {
      Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
    }
  }

  /// Generates a clean, unique file name using timestamp + random suffix + clean extension
  static String _generateCleanFileName(String fileName, {String prefixTag = ''}) {
    String ext = '';
    if (fileName.contains('.')) {
      ext = fileName.split('.').last.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }
    if (ext.isEmpty) {
      ext = 'png';
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(900000) + 100000;
    final prefix = prefixTag.isNotEmpty ? '${prefixTag}_' : '';
    return '$prefix${timestamp}_$randomSuffix.$ext';
  }

  /// Read an html.File as Uint8List via DataUrl Base64 decoding
  static Future<Uint8List?> _readHtmlFileBytes(html.File file) {
    final completer = Completer<Uint8List?>();
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      try {
        final String? dataUrl = reader.result?.toString();
        if (dataUrl != null && dataUrl.contains(',')) {
          final base64String = dataUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          completer.complete(bytes);
        } else {
          completer.complete(null);
        }
      } catch (e) {
        debugPrint('Error decoding file bytes: $e');
        completer.complete(null);
      }
    });
    reader.onError.listen((event) => completer.complete(null));
    reader.readAsDataUrl(file);
    return completer.future.timeout(const Duration(seconds: 40), onTimeout: () => null);
  }

  /// Uploads binary bytes directly to Supabase Storage inside the designated Customer Folder
  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String originalFileName,
    String? folderName,
    String prefixTag = '',
  }) async {
    try {
      await ensureInitialized();
      final uniqueName = _generateCleanFileName(originalFileName, prefixTag: prefixTag);
      final contentType = _getContentType(uniqueName);

      // Clean folder name to remove invalid URL characters while keeping Arabic & alphanumeric
      String cleanFolder = '';
      if (folderName != null && folderName.trim().isNotEmpty) {
        cleanFolder = folderName.trim().replaceAll(RegExp(r'[^\w\u0600-\u06FF-]'), '_').replaceAll(RegExp(r'_+'), '_');
      }

      final fullPath = cleanFolder.isNotEmpty ? '$cleanFolder/$uniqueName' : uniqueName;

      final client = Supabase.instance.client;
      await client.storage.from(bucketName).uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(fullPath);
      debugPrint('✅ Supabase uploadBinary SUCCESS in folder ($cleanFolder): $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Supabase uploadBinary Exception: $e');
      return null;
    }
  }

  /// Pick Logo inside Customer Folder
  static void pickLogo({
    String? folderName,
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
              final bytes = await _readHtmlFileBytes(file);
              if (bytes != null && bytes.isNotEmpty) {
                final fileUrl = await uploadBytes(
                  bytes: bytes,
                  originalFileName: file.name,
                  folderName: folderName,
                  prefixTag: 'logo',
                );
                onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } else {
                onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
              }
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
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
        debugPrint('Web pick logo error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            originalFileName: file.name,
            folderName: folderName,
            prefixTag: 'logo',
          );
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        } else {
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
        }
      }
    });
  }

  /// Pick Photos inside Customer Folder (concurrent uploads)
  static void pickPhotos({
    String? folderName,
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
            try {
              int index = 1;
              final uploadTasks = files.map((file) async {
                final currentIndex = index++;
                final bytes = await _readHtmlFileBytes(file);
                if (bytes != null && bytes.isNotEmpty) {
                  final fileUrl = await uploadBytes(
                    bytes: bytes,
                    originalFileName: file.name,
                    folderName: folderName,
                    prefixTag: 'photo_$currentIndex',
                  );
                  return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
                }
                return UploadedFileResult(fileName: file.name, fileUrl: null);
              }).toList();

              final results = await Future.wait(uploadTasks);
              onComplete(results);
            } catch (err) {
              debugPrint('Error uploading photos: $err');
              onComplete([]);
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
        debugPrint('Web pick photos error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        onUploadStatusChanged(true);
        try {
          int index = 1;
          final uploadTasks = result.files.map((file) async {
            final currentIndex = index++;
            if (file.bytes != null) {
              final fileUrl = await uploadBytes(
                bytes: file.bytes!,
                originalFileName: file.name,
                folderName: folderName,
                prefixTag: 'photo_$currentIndex',
              );
              return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
            }
            return UploadedFileResult(fileName: file.name, fileUrl: null);
          }).toList();

          final results = await Future.wait(uploadTasks);
          onComplete(results);
        } catch (_) {
          onComplete([]);
        } finally {
          onUploadStatusChanged(false);
        }
      }
    });
  }

  /// Pick Profile Document inside Customer Folder
  static void pickProfileDocument({
    String? folderName,
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
              final bytes = await _readHtmlFileBytes(file);
              if (bytes != null && bytes.isNotEmpty) {
                final fileUrl = await uploadBytes(
                  bytes: bytes,
                  originalFileName: file.name,
                  folderName: folderName,
                  prefixTag: 'profile',
                );
                onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
              } else {
                onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
              }
            } catch (_) {
              onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
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
        debugPrint('Web pick profile error: $err');
      }
    }

    // Universal / Non-web fallback
    FilePicker.platform.pickFiles(type: FileType.any, withData: true).then((result) async {
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            originalFileName: file.name,
            folderName: folderName,
            prefixTag: 'profile',
          );
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
        } else {
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: null));
        }
      }
    });
  }

  static String _getContentType(String filename) {
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
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
      case 'gif':
        return 'image/gif';
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
