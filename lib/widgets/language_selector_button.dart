import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return PopupMenuButton<AppLanguage>(
          tooltip: 'اختر اللغة / Language: ${currentLang.name}',
          offset: const Offset(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
          color: isDark ? AppTheme.cardDark : Colors.white,
          onSelected: (AppLanguage newLang) {
            currentLanguageNotifier.value = newLang;
          },
          itemBuilder: (BuildContext context) {
            return supportedLanguages.map((AppLanguage lang) {
              final isSelected = lang.code == currentLang.code;
              return PopupMenuItem<AppLanguage>(
                value: lang,
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? AppTheme.textWhite : AppTheme.textDark),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded, size: 15, color: AppTheme.primary),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: EdgeInsets.all(isMobile ? 5 : 7),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.translate_rounded,
              color: isDark ? AppTheme.accentGold : AppTheme.primary,
              size: isMobile ? 12.5 : 15,
            ),
          ),
        );
      },
    );
  }
}
