import 'dart:async';
import 'package:flutter/material.dart';
import '../../design_system/spacing.dart';

enum ToastType { success, error, info }

/// Composant Toast personnalisé haut de gamme pour afficher des alertes à l'utilisateur
class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    
    Color backgroundColor;
    Color borderColor;
    IconData icon;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case ToastType.success:
        backgroundColor = isDarkMode 
            ? const Color(0xE61B5E20) // Vert sombre translucide
            : const Color(0xE62E7D32);
        borderColor = Colors.greenAccent;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = isDarkMode 
            ? const Color(0xE6B71C1C) // Rouge sombre translucide
            : const Color(0xE6C62828);
        borderColor = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        backgroundColor = isDarkMode 
            ? const Color(0xE60D47A1) // Bleu sombre translucide
            : const Color(0xE61565C0);
        borderColor = Colors.blueAccent;
        icon = Icons.info_outline;
        break;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _ToastWidget(
            message: message,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            icon: icon,
            onDismiss: () {
              overlayEntry.remove();
            },
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _close();
    });
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: widget.borderColor.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: _close,
                child: const Icon(Icons.close, color: Colors.white70, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
