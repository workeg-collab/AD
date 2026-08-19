import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_storage_helper.dart';

class OrderNotifier {
  /// Send background order notification to client and company email via Supabase Edge Function & Resend
  static Future<bool> sendAdminNotification({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String businessName,
    required String category,
    String? domainChoice,
    String? logoInfo,
    String? photosInfo,
    String? profileInfo,
    String? aboutContent,
    String? contactInfo,
    String? notes,
    required String paymentMethod,
    String? paymentUrl,
  }) async {
    final payload = {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'client_email': customerEmail,
      'customerPhone': customerPhone,
      'businessName': businessName,
      'category': category,
      'domainChoice': domainChoice ?? '',
      'logoInfo': logoInfo ?? '',
      'photosInfo': photosInfo ?? '',
      'profileInfo': profileInfo ?? '',
      'aboutContent': aboutContent ?? '',
      'contactInfo': contactInfo ?? '',
      'notes': notes ?? '',
      'paymentMethod': paymentMethod,
      'paymentUrl': paymentUrl ?? '',
      'orderAmount': '299.00 SAR (4,247.74 EGP شامل الضريبة 5%)',
    };

    bool isSuccess = false;

    // 1. Invoke Supabase Edge Function: 'send-order-email'
    try {
      await SupabaseStorageHelper.ensureInitialized();
      final res = await Supabase.instance.client.functions.invoke(
        'send-order-email',
        body: payload,
      );
      if (res.status == 200 || res.status == 201) {
        isSuccess = true;
        debugPrint('✅ Supabase Edge Function (send-order-email) invoked successfully');
      } else {
        debugPrint('⚠️ Supabase Edge Function status: ${res.status}');
      }
    } catch (e) {
      debugPrint('⚠️ Supabase Edge Function invoke error: $e');
    }

    // 2. Also dispatch via Vercel Serverless Function /api/notify as guaranteed backup
    try {
      final serverlessUri = Uri.base.resolve('/api/notify');
      final res = await http.post(
        serverlessUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        isSuccess = true;
      }
    } catch (_) {}

    return isSuccess;
  }
}
