import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../controllers/home_controller.dart';

class TimePickerCard extends StatelessWidget {
  final HomeController controller;

  const TimePickerCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final label = controller.isWakeUpMode ? 'I want to wake up at' : 'I plan to sleep at';

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.xl,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _stepper(
                  value: controller.displayHour.toString().padLeft(2, '0'),
                  onUp: controller.incrementHour,
                  onDown: controller.decrementHour,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _gradientText(':'),
                ),
                _stepper(
                  value: controller.selectedMinute.value.toString().padLeft(2, '0'),
                  onUp: controller.incrementMinute,
                  onDown: controller.decrementMinute,
                ),
                const SizedBox(width: AppDimensions.md),
                _periodToggle(controller.period, controller.togglePeriod),
              ],
            ),

            const SizedBox(height: AppDimensions.md),

            GestureDetector(
              onTap: () => controller.openTimePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGlow,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Open time picker',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 100.ms, duration: 400.ms)
          .slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 400.ms);
    });
  }

  Widget _stepper({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _arrowButton(Icons.keyboard_arrow_up_rounded, onUp),
        _gradientText(value),
        _arrowButton(Icons.keyboard_arrow_down_rounded, onDown),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return _RepeatingArrowButton(icon: icon, onTrigger: onTap);
  }

  Widget _gradientText(String text) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppColors.primaryGradient.createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -2,
          height: 1,
        ),
      ),
    );
  }

  Widget _periodToggle(String period, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              period,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.swap_vert_rounded, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _RepeatingArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTrigger;

  const _RepeatingArrowButton({required this.icon, required this.onTrigger});

  @override
  State<_RepeatingArrowButton> createState() => _RepeatingArrowButtonState();
}

class _RepeatingArrowButtonState extends State<_RepeatingArrowButton> {
  static const _initialDelay = Duration(milliseconds: 400);
  static const _repeatInterval = Duration(milliseconds: 80);

  Timer? _initialTimer;
  Timer? _repeatTimer;

  void _start() {
    widget.onTrigger();
    _initialTimer = Timer(_initialDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) => widget.onTrigger());
    });
  }

  void _stop() {
    _initialTimer?.cancel();
    _repeatTimer?.cancel();
    _initialTimer = null;
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _start(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Icon(widget.icon, size: 28, color: AppColors.accent),
      ),
    );
  }
}
