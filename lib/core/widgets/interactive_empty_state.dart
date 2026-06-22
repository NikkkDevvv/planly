import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'bounce_button.dart';

class InteractiveEmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData? actionIcon;

  const InteractiveEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.actionIcon,
  });

  @override
  State<InteractiveEmptyState> createState() => _InteractiveEmptyStateState();
}

class _InteractiveEmptyStateState extends State<InteractiveEmptyState> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // Floating animation (continuous translation up-down)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -6.0).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for button icon (90 deg = 0.25 turns)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            if (widget.actionLabel != null && widget.onActionPressed != null) ...[
              const SizedBox(height: 24),
              BounceButton(
                onTap: () {
                  _rotateController.forward().then((_) => _rotateController.reset());
                  widget.onActionPressed!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.actionIcon != null) ...[
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(widget.actionIcon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
