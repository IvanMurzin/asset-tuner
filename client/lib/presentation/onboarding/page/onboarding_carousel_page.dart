import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_carousel_storage.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class OnboardingCarouselPage extends StatefulWidget {
  const OnboardingCarouselPage({super.key});

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onPrimaryAction() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
      return;
    }
    await getIt<OnboardingCarouselStorage>().setCompleted();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final radius = context.dsRadius;

    final titles = [
      l10n.onboardingCarouselTitle1,
      l10n.onboardingCarouselTitle2,
      l10n.onboardingCarouselTitle3,
    ];
    final bodies = [
      l10n.onboardingCarouselBody1,
      l10n.onboardingCarouselBody2,
      l10n.onboardingCarouselBody3,
    ];
    final buttonLabel =
        _currentPage < 2 ? l10n.onboardingCarouselNext : l10n.onboardingCarouselGetStarted;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(spacing.s24),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(radius.r16),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.7),
                            ),
                            boxShadow: context.dsElevation.e1,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titles[index],
                                style: typography.h2,
                              ),
                              SizedBox(height: spacing.s12),
                              Text(
                                bodies[index],
                                style: typography.body.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s16,
                spacing.s24,
                spacing.s24,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: spacing.s4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? colors.primary
                              : colors.border,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.s24),
                  DSButton(
                    label: buttonLabel,
                    fullWidth: true,
                    onPressed: _onPrimaryAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
