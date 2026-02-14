import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_carousel_storage.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_backdrop.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_footer.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_header.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_slide_content.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_glass_card.dart';

class OnboardingCarouselPage extends StatefulWidget {
  const OnboardingCarouselPage({super.key});

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage> {
  static const _pageCount = 3;

  late final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await getIt<OnboardingCarouselStorage>().setCompleted();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _nextOrComplete(AppLocalizations l10n) async {
    HapticFeedback.lightImpact();

    final isLast = _currentPage == _pageCount - 1;
    if (isLast) {
      await _complete();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToLast() async {
    HapticFeedback.selectionClick();
    await _pageController.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final isLast = _currentPage == _pageCount - 1;
    final primaryLabel =
        isLast ? l10n.onboardingCarouselGetStarted : l10n.onboardingCarouselNext;

    final slides = _OnboardingSlideData.buildAll(l10n);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: OnboardingCarouselBackdrop(
              page: _currentPage,
              primary: colors.primary,
              surface: colors.surface,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                OnboardingCarouselHeader(
                  isLastPage: isLast,
                  onSkip: _goToLast,
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, _) {
                      final page = _pageController.hasClients
                          ? (_pageController.page ?? _currentPage.toDouble())
                          : _currentPage.toDouble();

                      return PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: _pageCount,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final delta =
                              (page - index).clamp(-1.0, 1.0);
                          final t = 1.0 - delta.abs();
                          final scale = lerpDouble(0.92, 1.0, t)!;
                          final opacity = lerpDouble(0.55, 1.0, t)!;
                          final slide = slides[index];

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: spacing.s24),
                                child: OnboardingGlassCard(
                                  child: Padding(
                                    padding: EdgeInsets.all(spacing.s24),
                                    child: OnboardingCarouselSlideContent(
                                      icon: slide.icon,
                                      title: slide.title,
                                      body: slide.body,
                                      chipLabels: slide.chipLabels,
                                      parallaxOffset: delta,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                OnboardingCarouselFooter(
                  pageCount: _pageCount,
                  currentPage: _currentPage,
                  primaryLabel: primaryLabel,
                  onBack: _currentPage > 0
                      ? () async {
                          HapticFeedback.selectionClick();
                          await _pageController.previousPage(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      : null,
                  onPrimary: () => _nextOrComplete(l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.body,
    required this.chipLabels,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> chipLabels;

  static List<_OnboardingSlideData> buildAll(AppLocalizations l10n) {
    return [
      _OnboardingSlideData(
        icon: Icons.savings_rounded,
        title: l10n.onboardingCarouselTitle1,
        body: l10n.onboardingCarouselBody1,
        chipLabels: [
          l10n.onboardingCarouselChip1First,
          l10n.onboardingCarouselChip1Second,
        ],
      ),
      _OnboardingSlideData(
        icon: Icons.currency_exchange_rounded,
        title: l10n.onboardingCarouselTitle2,
        body: l10n.onboardingCarouselBody2,
        chipLabels: [
          l10n.onboardingCarouselChip2First,
          l10n.onboardingCarouselChip2Second,
        ],
      ),
      _OnboardingSlideData(
        icon: Icons.auto_graph_rounded,
        title: l10n.onboardingCarouselTitle3,
        body: l10n.onboardingCarouselBody3,
        chipLabels: [
          l10n.onboardingCarouselChip3First,
          l10n.onboardingCarouselChip3Second,
        ],
      ),
    ];
  }
}
