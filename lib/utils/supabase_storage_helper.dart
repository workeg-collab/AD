import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

  /// Upload raw binary file bytes (Uint8List) directly to Supabase Storage
  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    // 1. Direct binary HTTP upload to Supabase Storage REST API
    try {
      final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/$bucketName/$uniquePath');

      final response = await http.post(
        uploadUri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': contentType.isNotEmpty ? contentType : 'application/octet-stream',
        },
        body: bytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$uniquePath';
        debugPrint('✅ Direct Supabase Upload Success: $publicUrl');
        return publicUrl;
      }
    } catch (e) {
      debugPrint('⚠️ Direct Supabase upload error: $e');
    }

    // 2. Serverless API bridge fallback with Base64 payload
    try {
      final base64Data = base64Encode(bytes);
      final response = await http.post(
        Uri.parse('/api/supabase-upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Data,
          'fileName': fileName,
          'fileType': contentType,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileUrl = data?['fileUrl'] as String?;
        if (fileUrl != null && fileUrl.startsWith('http')) {
          debugPrint('✅ Serverless Supabase Upload Success: $fileUrl');
          return fileUrl;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Serverless Supabase upload error: $e');
    }

    return null;
  }

  /// Pick and upload a single image (Logo) using file.bytes (Uint8List)
  static Future<UploadedFileResult?> pickAndUploadLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'webp', 'pdf', 'ai', 'eps'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (e) {
      debugPrint('Error in pickAndUploadLogo: $e');
    }
    return null;
  }

  /// Pick and upload multiple images (Photos) using file.bytes (Uint8List)
  static Future<List<UploadedFileResult>> pickAndUploadPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'svg', 'gif'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final List<UploadedFileResult> results = [];
        for (final file in result.files) {
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            final fileUrl = await uploadBytes(
              bytes: file.bytes!,
              fileName: file.name,
              contentType: _getContentType(file.name),
            );
            results.add(UploadedFileResult(fileName: file.name, fileUrl: fileUrl));
          } else {
            results.add(UploadedFileResult(fileName: file.name));
          }
        }
        return results;
      }
    } catch (e) {
      debugPrint('Error in pickAndUploadPhotos: $e');
    }
    return [];
  }

  /// Pick and upload company profile document using file.bytes (Uint8List)
  static Future<UploadedFileResult?> pickAndUploadProfileDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          final fileUrl = await uploadBytes(
            bytes: file.bytes!,
            fileName: file.name,
            contentType: _getContentType(file.name),
          );
          return UploadedFileResult(fileName: file.name, fileUrl: fileUrl);
        }
        return UploadedFileResult(fileName: file.name);
      }
    } catch (e) {
      debugPrint('Error in pickAndUploadProfileDocument: $e');
    }
    return null;
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
