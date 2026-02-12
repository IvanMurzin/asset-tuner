import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/add_asset_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AddAssetCubit>()..load(widget.accountId),
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
                extra: const PaywallArgs(
                  reason: PaywallReason.subaccountsLimit,
                ),
              );
              if (context.mounted && upgraded == true) {
                await context.read<AddAssetCubit>().load(widget.accountId);
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

          if (_nameController.text != state.name) {
            _nameController.value = _nameController.value.copyWith(
              text: state.name,
              selection: TextSelection.collapsed(offset: state.name.length),
            );
          }
          if (_balanceController.text != state.balanceText) {
            _balanceController.value = _balanceController.value.copyWith(
              text: state.balanceText,
              selection: TextSelection.collapsed(
                offset: state.balanceText.length,
              ),
            );
          }

          if (state.status == AddAssetStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.subaccountCreateTitle),
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
              appBar: DSAppBar(title: l10n.subaccountCreateTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<AddAssetCubit>().load(widget.accountId),
              ),
            );
          }

          final canAdd =
              state.selectedAssetId != null &&
              state.name.trim().isNotEmpty &&
              state.balanceText.trim().isNotEmpty &&
              !state.isSaving;

          return Scaffold(
            appBar: DSAppBar(title: l10n.subaccountCreateTitle),
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
                        title: l10n.subaccountCreateTitle,
                        message: _failureMessage(l10n, state.failureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    DSTextField(
                      label: l10n.accountsNameLabel,
                      hintText: l10n.subaccountNameHint,
                      controller: _nameController,
                      enabled: !state.isSaving,
                      errorText: _nameErrorText(l10n, state.nameError),
                      onChanged: context.read<AddAssetCubit>().updateName,
                    ),
                    SizedBox(height: spacing.s12),
                    DSDecimalField(
                      label: l10n.addBalanceAmountLabel,
                      controller: _balanceController,
                      enabled: !state.isSaving,
                      errorText: _balanceErrorText(l10n, state.balanceError),
                      onChanged: context.read<AddAssetCubit>().updateBalance,
                    ),
                    SizedBox(height: spacing.s12),
                    DSSearchField(
                      hintText: l10n.assetSearchHint,
                      onChanged: context.read<AddAssetCubit>().updateQuery,
                    ),
                    SizedBox(height: spacing.s12),
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

                                  return DSListRow(
                                    title: asset.code,
                                    subtitle:
                                        '${asset.name} · ${_kindLabel(l10n, asset.kind)}',
                                    selected: selected,
                                    trailing: selected
                                        ? Icon(
                                            Icons.check_circle,
                                            color: colors.primary,
                                          )
                                        : Text(
                                            l10n.subaccountCurrencyLabel,
                                            style: typography.caption.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                          ),
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
                      label: l10n.subaccountCreateCta,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: canAdd
                          ? context.read<AddAssetCubit>().addSelected
                          : null,
                    ),
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

  String? _nameErrorText(AppLocalizations l10n, String? code) {
    return switch (code) {
      'required' => l10n.accountsNameRequired,
      _ => null,
    };
  }

  String? _balanceErrorText(AppLocalizations l10n, String? code) {
    return switch (code) {
      'required' => l10n.addBalanceValidationAmount,
      'invalid' => l10n.errorValidation,
      _ => null,
    };
  }

  String _kindLabel(AppLocalizations l10n, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => l10n.assetKindFiat,
      AssetKind.crypto => l10n.assetKindCrypto,
    };
  }
}
