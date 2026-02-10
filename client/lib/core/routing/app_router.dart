import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/preview/ds_preview_page.dart';
import 'package:asset_tuner/presentation/auth/page/otp_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_in_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_up_page.dart';
import 'package:asset_tuner/presentation/auth/page/splash_page.dart';
import 'package:asset_tuner/presentation/onboarding/page/base_currency_page.dart';
import 'package:asset_tuner/presentation/overview/page/overview_page.dart';
import 'package:asset_tuner/presentation/paywall/page/paywall_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: AppRoutes.home, builder: (context, state) => const SplashPage()),
    GoRoute(path: AppRoutes.designSystem, builder: (context, state) => const DSPreviewPage()),
    GoRoute(path: AppRoutes.signIn, builder: (context, state) => const SignInPage()),
    GoRoute(path: AppRoutes.signUp, builder: (context, state) => const SignUpPage()),
    GoRoute(path: AppRoutes.otp, builder: (context, state) => const OtpPage()),
    GoRoute(
      path: AppRoutes.onboardingBaseCurrency,
      builder: (context, state) => const BaseCurrencyPage(),
    ),
    GoRoute(path: AppRoutes.overview, builder: (context, state) => const OverviewPage()),
    GoRoute(path: AppRoutes.paywall, builder: (context, state) => const PaywallPage()),
  ],
);
