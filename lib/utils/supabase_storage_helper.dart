import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
  static String _generateCleanFileName(PlatformFile file) {
    String ext = (file.extension ?? '').toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (ext.isEmpty && file.name.contains('.')) {
      ext = file.name.split('.').last.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }
    if (ext.isEmpty) {
      ext = 'png';
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(900000) + 100000;
    return '${timestamp}_$randomSuffix.$ext';
  }

  /// Uploads in-memory file bytes directly using supabase.storage.from('orders').uploadBinary(...)
  static Future<String?> uploadPlatformFile(PlatformFile file) async {
    if (file.bytes == null || file.bytes!.isEmpty) {
      debugPrint('❌ Supabase Upload Failed: file.bytes is null or empty!');
      return null;
    }

    try {
      await ensureInitialized();
      final uniqueName = _generateCleanFileName(file);
      final contentType = _getContentType(uniqueName);

      final client = Supabase.instance.client;
      await client.storage.from(bucketName).uploadBinary(
            uniqueName,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(uniqueName);
      debugPrint('✅ Supabase Upload SUCCESS: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Supabase Upload Exception: $e');
      return null;
    }
  }

  /// Pick Logo using FilePicker withData: true & uploadBinary
  static Future<void> pickLogo({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(UploadedFileResult result) onComplete,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'webp', 'gif', 'ico', 'heic'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadPlatformFile(file);
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
          return;
        }
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
      onUploadStatusChanged(false);
    }
  }

  /// Pick Photos using FilePicker withData: true & uploadBinary (concurrent)
  static Future<void> pickPhotos({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(List<UploadedFileResult> results) onComplete,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'webp', 'gif', 'heic'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        onUploadStatusChanged(true);
        final uploadTasks = result.files.map((file) async {
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            final fileUrl = await uploadPlatformFile(file);
            return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
          }
          return UploadedFileResult(fileName: file.name, fileUrl: null);
        }).toList();

        final results = await Future.wait(uploadTasks);
        onUploadStatusChanged(false);
        onComplete(results);
        return;
      }
    } catch (e) {
      debugPrint('Error picking photos: $e');
      onUploadStatusChanged(false);
    }
  }

  /// Pick Profile Document using FilePicker withData: true & uploadBinary
  static Future<void> pickProfileDocument({
    required Function(bool isUploading) onUploadStatusChanged,
    required Function(UploadedFileResult result) onComplete,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'rtf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          onUploadStatusChanged(true);
          final fileUrl = await uploadPlatformFile(file);
          onUploadStatusChanged(false);
          onComplete(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
          return;
        }
      }
    } catch (e) {
      debugPrint('Error picking profile: $e');
      onUploadStatusChanged(false);
    }
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
