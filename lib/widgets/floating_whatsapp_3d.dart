import 'package:flutter/material.dart';
import '../utils/whatsapp_helper.dart';

class FloatingWhatsApp3D extends StatefulWidget {
  const FloatingWhatsApp3D({super.key});

  @override
  State<FloatingWhatsApp3D> createState() => _FloatingWhatsApp3DState();
}

class _FloatingWhatsApp3DState extends State<FloatingWhatsApp3D>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3D vertical offset calculation
    final double offsetY = _isPressed
        ? 4.0
        : (_isHovered ? -4.0 : 0.0);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            WhatsAppHelper.launchWhatsApp();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(0, offsetY, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              // 3D Multi-Layer Gradient (Glossy Top Highlight to Rich Base)
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF34D399), // Top bright highlight
                  Color(0xFF25D366), // Core WhatsApp green
                  Color(0xFF059669), // 3D Bottom shade
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              // 3D Bevel Top Inset Border
              border: Border.all(
                color: const Color(0xFFA7F3D0).withValues(alpha: 0.8),
                width: 1.5,
              ),
              // Multi-layered 3D Box Shadow with depth
              boxShadow: [
                // Bottom 3D Extrusion Shadow
                BoxShadow(
                  color: const Color(0xFF047857),
                  offset: Offset(0, _isPressed ? 2 : 6),
                  blurRadius: 0, // Solid 3D edge
                ),
                // Soft Ambient Drop Shadow
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: 0.45),
                  offset: Offset(0, _isHovered ? 14 : 10),
                  blurRadius: _isHovered ? 24 : 16,
                  spreadRadius: 2,
                ),
                // Dark floor contact shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 12),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D Pulse Notification Dot
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                    ),
                    const Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFACC15), // Gold online dot
                          border: Border.all(color: const Color(0xFF059669), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'تواصل مباشر',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFECFDF5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'واتساب المبيعات 💬',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
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
  }
}
