import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/balance/bloc/asset_position_detail_cubit.dart';
import 'package:asset_tuner/presentation/balance/widget/asset_position_detail_actions_row.dart';
import 'package:asset_tuner/presentation/balance/widget/asset_position_detail_header_card.dart';
import 'package:asset_tuner/presentation/balance/widget/asset_position_detail_loading_skeleton.dart';
import 'package:asset_tuner/presentation/balance/widget/asset_position_history_section.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AssetPositionDetailPage extends StatelessWidget {
  const AssetPositionDetailPage({
    super.key,
    required this.subaccountId,
    this.initialTitle,
  });

  final String subaccountId;
  final String? initialTitle;

  @override
  Widget build(BuildContext context) {
    return _AssetPositionDetailBody(
      subaccountId: subaccountId,
      initialTitle: initialTitle,
    );
  }
}

class _AssetPositionDetailBody extends StatefulWidget {
  const _AssetPositionDetailBody({
    required this.subaccountId,
    this.initialTitle,
  });

  final String subaccountId;
  final String? initialTitle;

  @override
  State<_AssetPositionDetailBody> createState() =>
      _AssetPositionDetailBodyState();
}

class _AssetPositionDetailBodyState extends State<_AssetPositionDetailBody> {
  bool _hasUnsyncedChange = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subaccountId = widget.subaccountId;
    final initialTitle = widget.initialTitle;

    return BlocConsumer<AssetPositionDetailCubit, AssetPositionDetailState>(
      listener: (context, state) {
        final navigation = state.navigation;
        if (navigation == null) {
          return;
        }
        context.read<AssetPositionDetailCubit>().consumeNavigation();
        switch (navigation.destination) {
          case AssetPositionDetailDestination.signIn:
            context.go(AppRoutes.signIn);
            break;
          case AssetPositionDetailDestination.backDeleted:
            context.read<OverviewCubit>().refresh();
            context.pop(true);
            break;
        }
      },
      builder: (context, state) {
        final spacing = context.dsSpacing;
        final title =
            initialTitle ??
            state.subaccountName ??
            state.assetCode ??
            l10n.notAvailable;

        if (state.status == AssetPositionDetailStatus.loading) {
          return Scaffold(
            appBar: DSAppBar(title: title),
            body: SafeArea(child: const AssetPositionDetailLoadingSkeleton()),
          );
        }

        if (state.status == AssetPositionDetailStatus.error &&
            state.subaccountId == null) {
          return Scaffold(
            appBar: DSAppBar(title: title),
            body: DSInlineError(
              title: l10n.splashErrorTitle,
              message: state.failureMessage ?? l10n.errorGeneric,
              actionLabel: l10n.splashRetry,
              onAction: () => context.read<AssetPositionDetailCubit>().load(
                subaccountId: subaccountId,
              ),
            ),
          );
        }

        final baseCurrency = state.baseCurrency ?? 'USD';
        final current = state.currentBalance ?? Decimal.zero;
        final canLoadMore = state.nextCursor != null && !state.isLoadingMore;
        void onBalanceUpdated() => setState(() => _hasUnsyncedChange = true);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.pop(_hasUnsyncedChange);
            }
          },
          child: Scaffold(
            appBar: DSAppBar(title: title),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing.s24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.bannerFailureCode != null) ...[
                          DSInlineBanner(
                            title: title,
                            message: state.bannerFailureCode != null
                                ? (state.bannerFailureMessage ??
                                      l10n.errorGeneric)
                                : l10n.errorGeneric,
                            variant: DSInlineBannerVariant.danger,
                          ),
                          SizedBox(height: spacing.s12),
                        ],
                        AssetPositionDetailHeaderCard(
                          subaccountName: state.subaccountName,
                          accountName: state.accountName,
                          assetCode: state.assetCode,
                          baseCurrency: baseCurrency,
                          currentBalance: current,
                          convertedValue: state.convertedValue,
                          ratesAsOf: state.ratesAsOf,
                        ),
                        if (state.isUnpriced) ...[
                          SizedBox(height: spacing.s12),
                          DSInlineBanner(
                            title: l10n.unpriced,
                            message: l10n.positionUnpricedHint,
                            variant: DSInlineBannerVariant.warning,
                          ),
                        ],
                        SizedBox(height: spacing.s16),
                        AssetPositionDetailActionsRow(
                          isEnabled: !state.isMutating,
                          updateLabel: l10n.subaccountUpdateBalanceCta,
                          renameLabel: l10n.subaccountRenameCta,
                          deleteLabel: l10n.subaccountDeleteCta,
                          onUpdate: () async {
                            final saved = await context.push<bool>(
                              AppRoutes.addBalance.replaceFirst(
                                ':id',
                                subaccountId,
                              ),
                            );
                            if (context.mounted) {
                              if (saved == true) {
                                context.read<OverviewCubit>().refresh();
                                onBalanceUpdated();
                                context
                                    .read<AssetPositionDetailCubit>()
                                    .refresh();
                              }
                            }
                          },
                          onRename: () async {
                            final name = await _showRenameDialog(
                              context,
                              initial: state.subaccountName ?? '',
                            );
                            if (name == null || !context.mounted) {
                              return;
                            }
                            await context
                                .read<AssetPositionDetailCubit>()
                                .rename(name);
                            if (context.mounted) {
                              onBalanceUpdated();
                              context
                                  .read<AssetPositionDetailCubit>()
                                  .refresh();
                            }
                          },
                          onDelete: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              l10n,
                            );
                            if (!confirmed || !context.mounted) {
                              return;
                            }
                            await context
                                .read<AssetPositionDetailCubit>()
                                .deleteSubaccount();
                          },
                        ),
                        SizedBox(height: spacing.s24),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                      child: state.status == AssetPositionDetailStatus.error
                          ? DSInlineError(
                              title: l10n.splashErrorTitle,
                              message:
                                  state.failureMessage ?? l10n.errorGeneric,
                              actionLabel: l10n.splashRetry,
                              onAction: () => context
                                  .read<AssetPositionDetailCubit>()
                                  .load(subaccountId: subaccountId),
                            )
                          : AssetPositionHistorySection(
                              entries: state.entries,
                              assetCode: state.assetCode,
                              baseCurrency: baseCurrency,
                              currentBalance: current,
                              convertedValue: state.convertedValue,
                              isLoadingMore: state.isLoadingMore,
                              canLoadMore: canLoadMore,
                              onLoadMore: () => context
                                  .read<AssetPositionDetailCubit>()
                                  .loadMore(),
                              onAddBalance: () async {
                                final saved = await context.push<bool>(
                                  AppRoutes.addBalance.replaceFirst(
                                    ':id',
                                    subaccountId,
                                  ),
                                );
                                if (context.mounted) {
                                  if (saved == true) {
                                    context.read<OverviewCubit>().refresh();
                                    onBalanceUpdated();
                                    context
                                        .read<AssetPositionDetailCubit>()
                                        .refresh();
                                  }
                                }
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.subaccountDeleteConfirmTitle,
        content: Text(l10n.subaccountDeleteConfirmBody),
        primaryLabel: l10n.subaccountDeleteCta,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<String?> _showRenameDialog(
    BuildContext context, {
    required String initial,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<String?>(
      context: context,
      builder: (_) => _RenameSubaccountDialog(l10n: l10n, initial: initial),
    );
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}

class _RenameSubaccountDialog extends StatefulWidget {
  const _RenameSubaccountDialog({required this.l10n, required this.initial});

  final AppLocalizations l10n;
  final String initial;

  @override
  State<_RenameSubaccountDialog> createState() =>
      _RenameSubaccountDialogState();
}

class _RenameSubaccountDialogState extends State<_RenameSubaccountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSDialog(
      title: widget.l10n.subaccountRenameTitle,
      content: DSTextField(
        label: widget.l10n.accountsNameLabel,
        controller: _controller,
      ),
      primaryLabel: widget.l10n.save,
      secondaryLabel: widget.l10n.cancel,
      onSecondary: () => Navigator.of(context).pop(),
      onPrimary: () {
        final value = _controller.text.trim();
        if (value.isEmpty) {
          return;
        }
        Navigator.of(context).pop(value);
      },
    );
  }
}
