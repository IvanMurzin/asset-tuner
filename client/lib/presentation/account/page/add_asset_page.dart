import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/add_asset_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

class AddAssetPage extends StatelessWidget {
  const AddAssetPage({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AddAssetCubit>()..load(accountId),
      child: BlocConsumer<AddAssetCubit, AddAssetState>(
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AddAssetCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AddAssetDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case AddAssetDestination.paywall:
              final upgraded = await context.push<bool>(
                AppRoutes.paywall,
                extra: const PaywallArgs(reason: PaywallReason.positionsLimit),
              );
              if (context.mounted && upgraded == true) {
                await context.read<AddAssetCubit>().load(accountId);
              }
              break;
            case AddAssetDestination.backAdded:
              context.pop(true);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final colors = context.dsColors;
          final typography = context.dsTypography;

          if (state.status == AddAssetStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.assetAddTitle),
              body: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSSkeleton(height: 18),
                      SizedBox(height: spacing.s12),
                      DSSkeleton(height: 18),
                      SizedBox(height: spacing.s12),
                      DSSkeleton(height: 18),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.status == AddAssetStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.assetAddTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AddAssetCubit>().load(accountId),
              ),
            );
          }

          final canAdd =
              state.selectedAssetId != null &&
              !state.duplicateError &&
              !state.isSaving;

          return Scaffold(
            appBar: DSAppBar(title: l10n.assetAddTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  spacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.failureCode != null) ...[
                      DSInlineBanner(
                        title: l10n.assetAddTitle,
                        message: _failureMessage(l10n, state.failureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if (state.duplicateError) ...[
                      DSInlineBanner(
                        title: l10n.assetAddTitle,
                        message: l10n.assetDuplicateError,
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if ((state.plan ?? 'free') != 'paid') ...[
                      DSInlineBanner(
                        title: l10n.assetAddTitle,
                        message: l10n.assetPaywallHint,
                        variant: DSInlineBannerVariant.info,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    DSSearchField(
                      hintText: l10n.assetSearchHint,
                      onChanged: context.read<AddAssetCubit>().updateQuery,
                    ),
                    SizedBox(height: spacing.s16),
                    Expanded(
                      child: state.visibleAssets.isEmpty
                          ? Center(
                              child: DSEmptyState(
                                title: l10n.assetNoMatchesTitle,
                                message: l10n.assetNoMatchesBody,
                                icon: Icons.search_off_outlined,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  context.dsRadius.r12,
                                ),
                                border: Border.all(color: colors.border),
                              ),
                              child: ListView.separated(
                                itemCount: state.visibleAssets.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final asset = state.visibleAssets[index];
                                  final selected =
                                      state.selectedAssetId == asset.id;
                                  final isDuplicate = state.existingAssetIds
                                      .contains(asset.id);

                                  return DSListRow(
                                    title: asset.code,
                                    subtitle:
                                        '${asset.name} · ${_kindLabel(l10n, asset.kind)}',
                                    selected: selected,
                                    trailing: isDuplicate
                                        ? Text(
                                            l10n.assetAlreadyAddedLabel,
                                            style: typography.caption.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                          )
                                        : null,
                                    onTap: state.isSaving
                                        ? null
                                        : () => context
                                              .read<AddAssetCubit>()
                                              .selectAsset(asset.id),
                                  );
                                },
                              ),
                            ),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.assetAddCta,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: canAdd
                          ? context.read<AddAssetCubit>().addSelected
                          : null,
                    ),
                    if (state.isSaving) ...[
                      SizedBox(height: spacing.s12),
                      const Center(child: DSLoader()),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
    return switch (code) {
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'forbidden' => l10n.errorForbidden,
      'not_found' => l10n.errorNotFound,
      'validation' => l10n.errorValidation,
      'conflict' => l10n.errorConflict,
      'rate_limited' => l10n.errorRateLimited,
      _ => l10n.errorGeneric,
    };
  }

  String _kindLabel(AppLocalizations l10n, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => l10n.assetKindFiat,
      AssetKind.crypto => l10n.assetKindCrypto,
    };
  }
}
