import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_carousel_storage.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class OnboardingCarouselPage extends StatefulWidget {
  const OnboardingCarouselPage({super.key});

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage> {
  static const _pageCount = 3;

  late final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _setCompleted() {
    return getIt<OnboardingCarouselStorage>().setCompleted();
  }

  Future<void> _completeToHome() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    final persistFuture = _setCompleted();
    if (mounted) {
      context.go(AppRoutes.home);
    }
    unawaited(persistFuture);
  }

  Future<void> _nextOrComplete() async {
    HapticFeedback.lightImpact();
    if (_isLastPage) {
      await _completeToHome();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToLast() async {
    HapticFeedback.selectionClick();
    await _pageController.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.dsColors;

    final slides = _OnboardingSlideData.buildAll(l10n);
    final primaryLabel = _isLastPage
        ? l10n.onboardingCarouselGetStarted
        : l10n.onboardingContinue;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _OnboardingSlideContent(
                    slide: slide,
                    showSkip: index != _pageCount - 1,
                    onSkip: _goToLast,
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),
          ),
          _OnboardingBottomBar(
            pageCount: _pageCount,
            currentPage: _currentPage,
            primaryLabel: primaryLabel,
            onPrimaryPressed: _nextOrComplete,
            isPrimaryLoading: _isCompleting,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideContent extends StatelessWidget {
  const _OnboardingSlideContent({
    required this.slide,
    required this.showSkip,
    required this.onSkip,
    required this.isActive,
  });

  final _OnboardingSlideData slide;
  final bool showSkip;
  final VoidCallback onSkip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s24,
        spacing.s12,
        spacing.s24,
        spacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerRight,
              child: showSkip
                  ? TextButton(
                      onPressed: onSkip,
                      child: Text(
                        AppLocalizations.of(context)!.onboardingCarouselSkip,
                        style: typography.body.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: spacing.s8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: AnimatedOpacity(
                      opacity: isActive ? 1 : 0.78,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSlide(
                        offset: isActive ? Offset.zero : const Offset(0, 0.03),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (slide.kind ==
                                  _OnboardingSlideKind.realSetup) ...[
                                _OnboardingTitle(slide: slide),
                                SizedBox(height: spacing.s24),
                                _OnboardingHero(
                                  slide: slide,
                                  isActive: isActive,
                                ),
                              ] else ...[
                                _OnboardingHero(
                                  slide: slide,
                                  isActive: isActive,
                                ),
                                SizedBox(height: spacing.s32),
                                _OnboardingTitle(slide: slide),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.slide});

  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Column(
      children: [
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: typography.h1.copyWith(
            height: 1.28,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: spacing.s12),
        Text(
          slide.body,
          textAlign: TextAlign.center,
          style: typography.body.copyWith(
            color: colors.textSecondary,
            height: 1.45,
          ),
        ),
        if (slide.footnote != null) ...[
          SizedBox(height: spacing.s12),
          Text(
            slide.footnote!,
            textAlign: TextAlign.center,
            style: typography.caption.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.slide, required this.isActive});

  final _OnboardingSlideData slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1 : 0.985,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: switch (slide.kind) {
          _OnboardingSlideKind.totalWealth => const _OnboardingTotalWealthHero(
            key: ValueKey('hero_total'),
          ),
          _OnboardingSlideKind.realSetup => _OnboardingRealSetupHero(
            key: const ValueKey('hero_setup'),
            accounts: slide.previewAccounts,
          ),
          _OnboardingSlideKind.quickUpdates => _OnboardingQuickUpdatesHero(
            key: const ValueKey('hero_quick'),
            caption: slide.heroCaption ?? '',
          ),
        },
      ),
    );
  }
}

class _OnboardingTotalWealthHero extends StatelessWidget {
  const _OnboardingTotalWealthHero({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final colors = context.dsColors;

    return Container(
      width: double.infinity,
      height: 252,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryHover, colors.primary],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: colors.neutral0,
              borderRadius: BorderRadius.circular(radius.r16),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.query_stats_rounded,
              color: colors.primary,
              size: 34,
            ),
          ),
          SizedBox(height: spacing.s24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniBalanceSquare(opacity: 0.24),
              SizedBox(width: spacing.s12),
              _MiniBalanceSquare(opacity: 0.30),
              SizedBox(width: spacing.s12),
              _MiniBalanceSquare(opacity: 0.24),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBalanceSquare extends StatelessWidget {
  const _MiniBalanceSquare({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = context.dsRadius;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.neutral0.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius.r8),
      ),
    );
  }
}

class _OnboardingRealSetupHero extends StatelessWidget {
  const _OnboardingRealSetupHero({super.key, required this.accounts});

  final List<_OnboardingAccountPreview> accounts;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Column(
      children: [
        for (var i = 0; i < accounts.length; i++) ...[
          _OnboardingAccountCardPreview(item: accounts[i]),
          if (i != accounts.length - 1) SizedBox(height: spacing.s12),
        ],
      ],
    );
  }
}

class _OnboardingAccountCardPreview extends StatelessWidget {
  const _OnboardingAccountCardPreview({required this.item});

  final _OnboardingAccountPreview item;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final radius = context.dsRadius;

    return DSCard(
      elevation: DSElevationLevel.level0,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s12,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _previewGradientColors(context, item.scheme),
              ),
            ),
            child: Icon(item.icon, size: 18, color: colors.neutral0),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: typography.h3),
                SizedBox(height: spacing.s4),
                Wrap(
                  spacing: spacing.s12,
                  runSpacing: spacing.s4,
                  children: item.currencies
                      .map(
                        (currency) => Text(
                          currency,
                          style: typography.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _previewGradientColors(
    BuildContext context,
    _OnboardingPreviewScheme scheme,
  ) {
    final colors = context.dsColors;
    return switch (scheme) {
      _OnboardingPreviewScheme.wallet => [colors.primary, colors.info],
      _OnboardingPreviewScheme.bank => [colors.success, colors.info],
      _OnboardingPreviewScheme.cash => [colors.warning, colors.danger],
    };
  }
}

class _OnboardingQuickUpdatesHero extends StatelessWidget {
  const _OnboardingQuickUpdatesHero({super.key, required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final typography = context.dsTypography;

    return Container(
      width: double.infinity,
      height: 252,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryHover, colors.primary],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: colors.neutral0,
              borderRadius: BorderRadius.circular(radius.r16),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: spacing.s16),
          Text(
            caption,
            style: typography.caption.copyWith(
              color: colors.neutral0.withValues(alpha: 0.88),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBottomBar extends StatelessWidget {
  const _OnboardingBottomBar({
    required this.pageCount,
    required this.currentPage,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.isPrimaryLoading,
  });

  final int pageCount;
  final int currentPage;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final bool isPrimaryLoading;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.s24,
            spacing.s24,
            spacing.s24,
            spacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OnboardingDots(pageCount: pageCount, currentPage: currentPage),
              SizedBox(height: spacing.s16),
              DSButton(
                label: primaryLabel,
                fullWidth: true,
                isLoading: isPrimaryLoading,
                onPressed: isPrimaryLoading ? null : onPrimaryPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({required this.pageCount, required this.currentPage});

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(horizontal: spacing.s4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isActive
                ? colors.primary
                : colors.textTertiary.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}

enum _OnboardingSlideKind { totalWealth, realSetup, quickUpdates }

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.kind,
    required this.title,
    required this.body,
    this.heroCaption,
    this.footnote,
    this.previewAccounts = const [],
  });

  final _OnboardingSlideKind kind;
  final String title;
  final String body;
  final String? heroCaption;
  final String? footnote;
  final List<_OnboardingAccountPreview> previewAccounts;

  static List<_OnboardingSlideData> buildAll(AppLocalizations l10n) {
    return [
      _OnboardingSlideData(
        kind: _OnboardingSlideKind.totalWealth,
        title: l10n.onboardingCarouselTitle1,
        body: l10n.onboardingCarouselBody1,
      ),
      _OnboardingSlideData(
        kind: _OnboardingSlideKind.realSetup,
        title: l10n.onboardingCarouselTitle2,
        body: l10n.onboardingCarouselBody2,
        previewAccounts: [
          _OnboardingAccountPreview(
            title: 'TrustWallet',
            currencies: const ['BTC', 'ETH', 'USDT'],
            icon: Icons.account_balance_wallet_rounded,
            scheme: _OnboardingPreviewScheme.wallet,
          ),
          _OnboardingAccountPreview(
            title: l10n.accountsTypeBank,
            currencies: const ['USD', 'EUR'],
            icon: Icons.account_balance_rounded,
            scheme: _OnboardingPreviewScheme.bank,
          ),
          _OnboardingAccountPreview(
            title: l10n.accountsTypeCash,
            currencies: const ['GBP'],
            icon: Icons.payments_rounded,
            scheme: _OnboardingPreviewScheme.cash,
          ),
        ],
      ),
      _OnboardingSlideData(
        kind: _OnboardingSlideKind.quickUpdates,
        title: l10n.onboardingCarouselTitle3,
        body: l10n.onboardingCarouselBody3,
        footnote: l10n.onboardingCarouselBody3Footnote,
        heroCaption: l10n.onboardingCarouselQuickUpdatesCaption,
      ),
    ];
  }
}

class _OnboardingAccountPreview {
  const _OnboardingAccountPreview({
    required this.title,
    required this.currencies,
    required this.icon,
    required this.scheme,
  });

  final String title;
  final List<String> currencies;
  final IconData icon;
  final _OnboardingPreviewScheme scheme;
}

enum _OnboardingPreviewScheme { wallet, bank, cash }
