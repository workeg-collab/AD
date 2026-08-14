import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
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

  /// Generates a unique, URL-safe filename while preserving the original extension.
  static String _generateUniquePath(String originalFileName) {
    String ext = '';
    final dotIndex = originalFileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < originalFileName.length - 1) {
      ext = originalFileName.substring(dotIndex).toLowerCase();
      ext = ext.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '');
    }

    final safeBase = originalFileName
        .split('.')
        .first
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final shortBase = safeBase.length > 20 ? safeBase.substring(0, 20) : (safeBase.isEmpty ? 'file' : safeBase);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(900000) + 100000;

    return '${timestamp}_${randomSuffix}_$shortBase$ext';
  }

  /// Upload raw bytes directly to Supabase Storage endpoint with Serverless Bridge Fallback
  static Future<String?> uploadBytesDirect(Uint8List bytes, String originalFileName, {String? mimeType}) async {
    final uniquePath = _generateUniquePath(originalFileName);
    final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$uniquePath');
    final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';
    final contentType = (mimeType != null && mimeType.isNotEmpty)
        ? mimeType
        : _getContentType(originalFileName);

    // 1. Direct Supabase Storage Upload via HTTP POST (Handles up to 50MB)
    try {
      final response = await http
          .post(
            uploadUri,
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': contentType,
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Supabase Direct Bytes Upload SUCCESS: $publicUrl');
        return publicUrl;
      }
      debugPrint('❌ Supabase Direct Bytes Failed (${response.statusCode}): ${response.body}');
    } catch (e) {
      debugPrint('❌ Supabase Direct Bytes Exception: $e');
    }

    // 2. Fallback to Serverless Bridge on Web
    if (kIsWeb) {
      try {
        final base64String = base64Encode(bytes);
        final bridgeUri = Uri.base.resolve('/api/supabase-upload');
        final response = await http
            .post(
              bridgeUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'base64Data': base64String,
                'fileName': originalFileName,
                'fileType': contentType,
              }),
            )
            .timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['fileUrl'] != null) {
            final url = data['fileUrl'] as String;
            debugPrint('✅ Serverless Bridge Upload SUCCESS: $url');
            return url;
          }
        }
        debugPrint('❌ Bridge status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('❌ Bridge upload error: $e');
      }
    }

    return null;
  }

  /// Pick Logo synchronously on Web & Native
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
          final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
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

  /// Pick Photos synchronously on Web & Native (concurrent uploads)
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
            final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
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

  /// Pick Profile Document synchronously on Web & Native
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
          final fileUrl = await uploadBytesDirect(file.bytes!, file.name);
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
