import 'package:asset_tuner/core/local_storage/onboarding_paywall_storage.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FirstAuthPaywallCoordinator extends StatefulWidget {
  const FirstAuthPaywallCoordinator({
    super.key,
    required this.child,
    required this.authCubit,
    required this.profileCubit,
    required this.router,
    required this.revenueCatService,
    this.storage,
    this.onOpenPaywall,
  });

  final Widget child;
  final AuthCubit authCubit;
  final ProfileCubit profileCubit;
  final GoRouter router;
  final RevenueCatService revenueCatService;
  final OnboardingPaywallStorage? storage;
  final Future<void> Function()? onOpenPaywall;

  @override
  State<FirstAuthPaywallCoordinator> createState() => _FirstAuthPaywallCoordinatorState();
}

class _FirstAuthPaywallCoordinatorState extends State<FirstAuthPaywallCoordinator> {
  late final OnboardingPaywallStorage _storage = widget.storage ?? OnboardingPaywallStorage();
  bool _didAttemptInSession = false;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleReadyChanged();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          bloc: widget.authCubit,
          listenWhen: (previous, current) {
            return previous.isRevenueCatReady != current.isRevenueCatReady;
          },
          listener: (context, state) => _handleReadyChanged(),
        ),
        BlocListener<ProfileCubit, ProfileState>(
          bloc: widget.profileCubit,
          listenWhen: (previous, current) {
            return previous.isReady != current.isReady || previous.status != current.status;
          },
          listener: (context, state) => _handleReadyChanged(),
        ),
      ],
      child: widget.child,
    );
  }

  Future<void> _handleReadyChanged() async {
    if (_didAttemptInSession || _isOpening) {
      return;
    }
    if (!widget.authCubit.state.isRevenueCatReady || !widget.profileCubit.state.isReady) {
      return;
    }
    _didAttemptInSession = true;
    _isOpening = true;
    try {
      final seen = await _storage.getSeen();
      if (seen) {
        return;
      }
      final ready = await _ensurePaywallReady();
      if (!ready) {
        _didAttemptInSession = false;
        return;
      }
      if (widget.onOpenPaywall != null) {
        await _storage.setSeen();
        await widget.onOpenPaywall!.call();
        return;
      }
      await _storage.setSeen();
      await widget.router.push(
        AppRoutes.paywall,
        extra: const PaywallArgs(reason: PaywallReason.onboarding),
      );
    } finally {
      _isOpening = false;
    }
  }

  Future<bool> _ensurePaywallReady() async {
    const delays = <Duration>[Duration.zero, Duration(milliseconds: 500), Duration(seconds: 1)];
    for (final delay in delays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      try {
        final offerings = await widget.revenueCatService.getOfferings();
        if (offerings.current != null) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }
}
