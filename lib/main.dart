import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'utils/supabase_storage_helper.dart';
import 'views/home_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: SupabaseStorageHelper.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseStorageHelper.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }
  runApp(const SAApp());
}

class SAApp extends StatelessWidget {
  const SAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'SA Web Solutions | صفحات تعريفية خلال 6 ساعات بالسعودية بـ 299 ريال',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const HomePage(),
        );
      },
    );
  }
}
