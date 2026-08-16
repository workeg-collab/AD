import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/domain_checker.dart';
import 'order_modal.dart';

class DomainSearchModal extends StatefulWidget {
  const DomainSearchModal({super.key});

  @override
  State<DomainSearchModal> createState() => _DomainSearchModalState();
}

class _DomainSearchModalState extends State<DomainSearchModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<DomainSearchResult>? _results;
  String _searchedKeyword = '';

  final List<String> _quickSuggestions = [
    'riyadh-store',
    'saudi-brand',
    'golden-oud',
    'al-fajr',
    'smart-solutions',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch([String? term]) async {
    final query = term ?? _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchedKeyword = query;
      _results = null;
    });

    try {
      final results = await DomainChecker.searchAllBudgetExtensions(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = [];
        });
      }
    }
  }

  void _selectDomainAndOrder(String chosenDomain) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => OrderModal(initialDomain: chosenDomain),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return Directionality(
          textDirection: currentLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Dialog(
            backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: isMobile ? 16 : 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.radiusXl,
              side: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                width: 1.0,
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.primaryContainerDark
                                    : AppTheme.primaryContainer,
                                borderRadius: AppTheme.radiusSm,
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslations.tr('domain_modal_title'),
                                    style: TextStyle(
                                      fontSize: isMobile ? 14.5 : 17,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppTranslations.tr('domain_modal_sub'),
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : AppTheme.bgLight,
                            borderRadius: AppTheme.radiusSm,
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: AppTranslations.tr('domain_input_hint'),
                              hintTextDirection: currentLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _controller.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onSubmitted: (val) => _performSearch(val),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _performSearch(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSm,
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppTranslations.tr('domain_btn_search'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 13.5,
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Quick suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          AppTranslations.tr('domain_quick_examples'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                          ),
                        ),
                        ..._quickSuggestions.map((sug) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(
                                sug,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: isDark ? AppTheme.cardDark : const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSm),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              onPressed: () {
                                _controller.text = sug;
                                _performSearch(sug);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Search Results or Placeholder
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: AppTheme.primary),
                                const SizedBox(height: 16),
                                Text(
                                  _searchedKeyword.isNotEmpty
                                      ? '${AppTranslations.tr('domain_loading_text')} ($_searchedKeyword)'
                                      : AppTranslations.tr('domain_loading_text'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _results == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.primaryContainerDark
                                            : AppTheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.travel_explore_rounded,
                                        size: 40,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      AppTranslations.tr('domain_placeholder_title'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      AppTranslations.tr('domain_placeholder_sub'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _results!.isEmpty
                                ? Center(
                                    child: Text(
                                      AppTranslations.tr('domain_invalid_input'),
                                      style: const TextStyle(color: AppTheme.textMuted),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _results!.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final item = _results![index];
                                      return _buildDomainResultCard(
                                        context,
                                        item,
                                        isDark,
                                        textColor,
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDomainResultCard(
    BuildContext context,
    DomainSearchResult item,
    bool isDark,
    Color? textColor,
  ) {
    final isAvail = item.isAvailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isAvail
            ? (isDark ? AppTheme.primaryContainerDark : AppTheme.primaryContainer)
            : (isDark ? AppTheme.cardDark : AppTheme.bgLight),
        borderRadius: AppTheme.radiusSm,
        border: Border.all(
          color: isAvail
              ? AppTheme.primary.withValues(alpha: 0.4)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Domain Name & Status Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.fullDomain,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isAvail
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                        letterSpacing: 0.2,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 8),
                    if (isAvail)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: AppTheme.radiusSm,
                          border: Border.all(color: AppTheme.primary, width: 1),
                        ),
                        child: const Text(
                          'شامل الباقة 🎁',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      isAvail ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 14,
                      color: isAvail ? AppTheme.primary : AppTheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvail
                          ? 'متاح ومجاني (شامل الباقة) ✅'
                          : (item.fullDomain.split('.').first.length <= 4
                              ? 'غير متاح بالباقة ❌'
                              : AppTranslations.tr('domain_taken_text')),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isAvail ? AppTheme.primary : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          if (isAvail)
            ElevatedButton.icon(
              onPressed: () => _selectDomainAndOrder(item.fullDomain),
              icon: const Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
              label: Text(
                AppTranslations.tr('domain_select_and_order_btn'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSm,
                ),
                elevation: 0,
              ),
            )
          else
            Text(
              AppTranslations.tr('domain_unavailable_text'),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
