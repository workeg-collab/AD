import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return PopupMenuButton<AppLanguage>(
          tooltip: 'اختر اللغة / Select Language',
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    Text(lang.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? AppTheme.textWhite : AppTheme.textDark),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded, size: 16, color: AppTheme.primary),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentLang.flag, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  currentLang.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
