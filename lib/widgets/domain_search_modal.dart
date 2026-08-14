import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
    final textColor = theme.textTheme.bodyLarge?.color;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.5,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فحص واختيار اسم موقعك (مجاناً) 🌐',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'دومين خاص لعلامتك التجارية مشمول مجاناً بالسنة الأولى',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم محلك أو نشاطك (مثال: riyadh-store)',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (val) => _performSearch(val),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _performSearch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'فحص الآن 🔍',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
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
                  const Text(
                    'أمثلة سريعة: ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  ..._quickSuggestions.map((sug) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(
                          sug,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                            'جاري الفحص المباشر لجميع الامتدادات المتاحة لـ "$_searchedKeyword"...',
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
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.travel_explore_rounded,
                                  size: 48,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'ابحث عن اسم موقعك وشاهد الامتدادات المتاحة فوراً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'جميع الدومينات المتاحة مشمولة مجاناً مع عرض الـ 299 ريال',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _results!.isEmpty
                          ? const Center(
                              child: Text(
                                'يرجى إدخال اسم صحيح للبحث (حرفين أو أكثر بالإنجليزية أو العربية)',
                                style: TextStyle(color: AppTheme.textMuted),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAvail
            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
            : (isDark ? AppTheme.cardDark : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAvail
              ? const Color(0xFF10B981)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: isAvail ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Domain Name & Status Badge (NO PRICES DISPLAYED)
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvail
                            ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                            : AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 8),
                    if (isAvail)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981), width: 1),
                        ),
                        child: const Text(
                          'شامل الباقة مجاناً 🎁',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
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
                      color: isAvail ? const Color(0xFF10B981) : Colors.red.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvail ? 'متاح للحجز الفوري ✅' : 'محجوز مسبقاً وغير متاح ❌',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAvail ? const Color(0xFF10B981) : Colors.red.shade400,
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
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('اختيار وطلب 🚀'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            )
          else
            const Text(
              'غير متاح',
              style: TextStyle(
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
