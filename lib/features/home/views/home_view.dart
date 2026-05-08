import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/home_controller.dart';
import '../widgets/calculate_button.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/result_card.dart';
import '../widgets/time_picker_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppDimensions.lg),
                    ModeToggle(controller: controller),
                    const SizedBox(height: AppDimensions.md),
                    TimePickerCard(controller: controller),
                    const SizedBox(height: AppDimensions.md),
                    CalculateButton(controller: controller),
                    const SizedBox(height: AppDimensions.xl),
                    _buildResultsSection(),
                    const SizedBox(height: AppDimensions.xxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icon/icon.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
          onPressed: () => Get.toNamed(AppRoutes.history),
          tooltip: AppStrings.viewHistory,
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Obx(() {
      if (!controller.isCalculated.value) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(
                AppStrings.resultsTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGlow,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${controller.results.length} options',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.05, end: 0, duration: 300.ms),

          const SizedBox(height: 6),

          // Cycle explainer note
          Text(
            AppStrings.fallAsleepNote,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 300.ms),

          const SizedBox(height: AppDimensions.md),

          // Result cards list
          ...controller.results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            return ResultCard(
              result: result,
              index: index,
              onSetAlarm: () => controller.setAlarm(result.time),
            );
          }),

          const SizedBox(height: AppDimensions.md),

          // Educational note
          _buildCycleExplainerCard(),
        ],
      );
    });
  }

  Widget _buildCycleExplainerCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.accentGlow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.primaryStart.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              AppStrings.cycleExplainer,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms);
  }
}
