import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ADApp());
}

class ADApp extends StatelessWidget {
  const ADApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AD Web Solutions | صفحات تعريفية خلال 6 ساعات بالسعودية بـ 299 ريال',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
