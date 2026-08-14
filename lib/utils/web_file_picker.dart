import 'dart:async';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

class WebFilePicker {
  /// Pick an image or document file with 100% web & mobile browser compatibility
  static Future<String?> pickSingleFile({
    String accept = 'image/*',
    List<String>? allowedExtensions,
  }) async {
    if (kIsWeb) {
      try {
        final completer = Completer<String?>();
        final input = html.FileUploadInputElement()
          ..accept = accept
          ..multiple = false;

        input.click();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            completer.complete(files.first.name);
          } else {
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => null,
        );
      } catch (_) {
        // Fallback to FilePicker
      }
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.name;
      }
    } catch (_) {}

    return null;
  }

  /// Pick multiple images with 100% web & mobile browser compatibility
  static Future<List<String>> pickMultipleImages() async {
    if (kIsWeb) {
      try {
        final completer = Completer<List<String>>();
        final input = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = true;

        input.click();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            completer.complete(files.map((f) => f.name).toList());
          } else {
            completer.complete([]);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => [],
        );
      } catch (_) {
        // Fallback to FilePicker
      }
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.map((f) => f.name).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Pick company profile document (PDF, Word, PPT)
  static Future<String?> pickProfileDocument() async {
    if (kIsWeb) {
      try {
        final completer = Completer<String?>();
        final input = html.FileUploadInputElement()
          ..accept = '.pdf,.doc,.docx,.ppt,.pptx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ..multiple = false;

        input.click();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            completer.complete(files.first.name);
          } else {
            completer.complete(null);
          }
        });

        return await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () => null,
        );
      } catch (_) {
        // Fallback to FilePicker
      }
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.name;
      }
    } catch (_) {}

    return null;
  }
}
