import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_carousel_storage.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_splash_layout.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/page/splash_page.dart';

class HomeGatePage extends StatefulWidget {
  const HomeGatePage({super.key});

  @override
  State<HomeGatePage> createState() => _HomeGatePageState();
}

class _HomeGatePageState extends State<HomeGatePage> {
  bool? _carouselCompleted;

  @override
  void initState() {
    super.initState();
    _checkCarousel();
  }

  Future<void> _checkCarousel() async {
    final storage = getIt<OnboardingCarouselStorage>();
    final completed = await storage.getCompleted();
    if (!mounted) return;
    if (!completed) {
      context.go(AppRoutes.onboardingCarousel);
      return;
    }
    setState(() => _carouselCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_carouselCompleted != true) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(body: DSSplashLayout(title: l10n.appTitle, status: null));
    }
    return const SplashPage();
  }
}
