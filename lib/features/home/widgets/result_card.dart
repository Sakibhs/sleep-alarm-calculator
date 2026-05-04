import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/sleep_result_model.dart';

class ResultCard extends StatelessWidget {
  final SleepResultModel result;
  final int index;
  final VoidCallback onSetAlarm;

  const ResultCard({
    super.key,
    required this.result,
    required this.index,
    required this.onSetAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final qualityColor = _qualityColor(result.quality);
    final qualityGradient = _qualityGradient(result.quality);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: result.isHighlighted
              ? AppColors.primaryStart.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: result.isHighlighted ? 1.5 : 1,
        ),
        boxShadow: result.isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primaryStart.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          children: [
            // Highlighted banner
            if (result.isHighlighted) _buildHighlightBanner(),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(
                children: [
                  // Cycle indicator circle
                  _buildCycleIndicator(qualityGradient, qualityColor),

                  const SizedBox(width: AppDimensions.md),

                  // Time + details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _chip(
                              '${result.formattedDuration} ${AppStrings.sleepDuration}',
                              Icons.schedule,
                              AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            _chip(
                              '${result.cycleCount} ${AppStrings.cycles}',
                              Icons.loop,
                              qualityColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result.insightLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: qualityColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Set alarm button
                  _buildAlarmButton(qualityGradient),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 350.ms,
        )
        .slideX(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: 80 * index),
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildHighlightBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'RECOMMENDED',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleIndicator(Gradient gradient, Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${result.cycleCount}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmButton(Gradient gradient) {
    return GestureDetector(
      onTap: onSetAlarm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm_add_rounded, size: 20, color: Colors.white),
            const SizedBox(height: 2),
            Text(
              AppStrings.setAlarm,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _qualityColor(CycleQuality quality) {
    switch (quality) {
      case CycleQuality.best:
        return AppColors.cycleBest;
      case CycleQuality.ideal:
        return AppColors.cycleOptimal;
      case CycleQuality.good:
        return AppColors.cycleOptimal;
      case CycleQuality.minimum:
        return AppColors.cycleWarning;
      case CycleQuality.veryShort:
        return AppColors.cycleCritical;
    }
  }

  LinearGradient _qualityGradient(CycleQuality quality) {
    switch (quality) {
      case CycleQuality.best:
        return AppColors.bestGradient;
      case CycleQuality.ideal:
        return AppColors.optimalGradient;
      case CycleQuality.good:
        return AppColors.optimalGradient;
      case CycleQuality.minimum:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case CycleQuality.veryShort:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
    }
  }
}
