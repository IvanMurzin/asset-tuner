import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key, required this.args});

  final PaywallArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<PaywallCubit>()..load(reason: args.reason),
      child: BlocConsumer<PaywallCubit, PaywallState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<PaywallCubit>().consumeNavigation();
          switch (navigation.destination) {
            case PaywallDestination.closeUpgraded:
              context.pop(true);
          }
        },
        builder: (context, state) {
          if (state.status == PaywallStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == PaywallStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<PaywallCubit>().load(reason: args.reason),
              ),
            );
          }

          final isPaid = (state.plan ?? 'free') == 'paid';
          if (isPaid) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.paywallTitle),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.paywallAlreadyPaid,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => context.pop(true),
                        child: Text(l10n.paywallDismiss),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return PaywallView(
            displayCloseButton: true,
            onPurchaseCompleted: (customerInfo, storeTransaction) {
              context.read<PaywallCubit>().syncPlanAfterPurchase();
            },
            onRestoreCompleted: (_) {
              context.read<PaywallCubit>().syncPlanAfterPurchase();
            },
            onDismiss: () {
              context.pop(false);
            },
          );
        },
      ),
    );
  }
}
