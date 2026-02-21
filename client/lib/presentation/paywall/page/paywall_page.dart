import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == UserStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (!state.isAuthenticated) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: context.read<UserCubit>().bootstrap,
              ),
            );
          }

          final isPaid = state.profile?.plan == 'pro';
          if (isPaid) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: Center(
                child: FilledButton(
                  onPressed: () => context.pop(true),
                  child: Text(l10n.paywallDismiss),
                ),
              ),
            );
          }

          return PaywallView(
            displayCloseButton: true,
            onPurchaseCompleted: (_, _) async {
              await context.read<UserCubit>().syncSubscription();
              if (context.mounted) {
                await context.read<AssetsCubit>().refresh(silent: true);
              }
              if (context.mounted) {
                context.pop(true);
              }
            },
            onRestoreCompleted: (_) async {
              await context.read<UserCubit>().syncSubscription();
              if (context.mounted) {
                await context.read<AssetsCubit>().refresh(silent: true);
              }
              if (context.mounted) {
                context.pop(true);
              }
            },
            onDismiss: () => context.pop(false),
          );
        },
      ),
    );
  }
}
