import 'package:flutter/material.dart';
import '../utils/app_translations.dart';
import '../widgets/navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/trust_stats_section.dart';
import '../widgets/features_section.dart';
import '../widgets/demo_switcher.dart';
import '../widgets/pricing_section.dart';
import '../widgets/order_modal.dart';
import '../widgets/floating_whatsapp_3d.dart';
import '../widgets/footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _demosKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openOrderModal() {
    showDialog(
      context: context,
      builder: (context) => const OrderModal(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguageNotifier,
      builder: (context, currentLang, child) {
        return Directionality(
          textDirection: currentLang.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Navbar(
                    onOrderTap: () => _scrollToKey(_pricingKey),
                    onDemosTap: () => _scrollToKey(_demosKey),
                    onFeaturesTap: () => _scrollToKey(_featuresKey),
                  ),

                  HeroSection(
                    key: _heroKey,
                    onOrderTap: _openOrderModal,
                    onDemosTap: () => _scrollToKey(_demosKey),
                  ),

                  const TrustStatsSection(),

                  FeaturesSection(key: _featuresKey),

                  DemoSwitcher(
                    key: _demosKey,
                    onSelectTemplate: _openOrderModal,
                  ),

                  PricingSection(
                    key: _pricingKey,
                    onOpenOrderModal: _openOrderModal,
                  ),

                  const Footer(),
                ],
              ),
            ),
            floatingActionButton: const FloatingWhatsApp3D(),
          ),
        );
      },
    );
  }
}
