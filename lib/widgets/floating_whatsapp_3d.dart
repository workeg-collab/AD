import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/whatsapp_helper.dart';

class FloatingWhatsApp3D extends StatefulWidget {
  const FloatingWhatsApp3D({super.key});

  @override
  State<FloatingWhatsApp3D> createState() => _FloatingWhatsApp3DState();
}

class _FloatingWhatsApp3DState extends State<FloatingWhatsApp3D> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return Directionality(
          textDirection: currentLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: InkWell(
              onTap: () => WhatsAppHelper.launchWhatsApp(),
              borderRadius: AppTheme.radiusFull,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.whatsappGreen,
                  borderRadius: AppTheme.radiusFull,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.whatsappGreen.withValues(alpha: _isHovered ? 0.4 : 0.25),
                      blurRadius: _isHovered ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.tr('whatsapp_btn_top'),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF0FDF4),
                            height: 1.1,
                          ),
                        ),
                        Text(
                          AppTranslations.tr('whatsapp_btn_main'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
