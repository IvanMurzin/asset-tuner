import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/settings/bloc/base_currency_settings_cubit.dart';

class BaseCurrencySettingsPage extends StatelessWidget {
  const BaseCurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<BaseCurrencySettingsCubit>()..load(),
      child: BlocConsumer<BaseCurrencySettingsCubit, BaseCurrencySettingsState>(
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<BaseCurrencySettingsCubit>().consumeNavigation();
          switch (navigation.destination) {
            case BaseCurrencySettingsDestination.back:
              context.pop(state.currentCode);
              break;
            case BaseCurrencySettingsDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case BaseCurrencySettingsDestination.paywall:
              final upgraded = await context.push<bool>(AppRoutes.paywall);
              if (context.mounted && upgraded == true) {
                await context.read<BaseCurrencySettingsCubit>().load();
                final requested = navigation.requestedCode;
                if (requested != null && context.mounted) {
                  context.read<BaseCurrencySettingsCubit>().selectCurrency(
                    requested,
                  );
                }
              }
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;
          final radius = context.dsRadius;

          if (state.status == BaseCurrencySettingsStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == BaseCurrencySettingsStatus.error &&
              state.currencies.isEmpty) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
              body: DSInlineError(
                title: l10n.baseCurrencySettingsLoadErrorTitle,
                message: _failureMessage(l10n, state.loadFailureCode),
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<BaseCurrencySettingsCubit>().load(),
              ),
            );
          }

          final visible = state.visibleCurrencies;
          final query = state.query.trim();
          final showBrowseAll = query.length < 2 && !state.showAll;

          return Scaffold(
            appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
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
                    DSSectionTitle(
                      title: l10n.baseCurrencySettingsCurrentTitle,
                    ),
                    SizedBox(height: spacing.s12),
                    DSCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentCode ?? l10n.notAvailable,
                            style: typography.h2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: spacing.s4),
                          Text(
                            l10n.baseCurrencySettingsCurrentBody,
                            style: typography.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                    DSSectionTitle(title: l10n.baseCurrencySettingsPickerTitle),
                    SizedBox(height: spacing.s12),
                    Expanded(
                      child: DSCard(
                        padding: EdgeInsets.all(spacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSSearchField(
                              hintText: l10n.baseCurrencySettingsSearchHint,
                              onChanged: context
                                  .read<BaseCurrencySettingsCubit>()
                                  .updateQuery,
                            ),
                            SizedBox(height: spacing.s12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.baseCurrencySettingsSearchTip,
                                    style: typography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (showBrowseAll) ...[
                                  SizedBox(width: spacing.s12),
                                  DSButton(
                                    label: l10n.baseCurrencySettingsBrowseAll,
                                    variant: DSButtonVariant.secondary,
                                    onPressed: () => context
                                        .read<BaseCurrencySettingsCubit>()
                                        .showAll(),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: spacing.s16),
                            if (state.bannerType ==
                                    BaseCurrencySettingsBannerType
                                        .saveFailure &&
                                state.bannerFailureCode != null) ...[
                              DSInlineBanner(
                                title: l10n.baseCurrencySettingsTitle,
                                message: _failureMessage(
                                  l10n,
                                  state.bannerFailureCode,
                                ),
                                variant: DSInlineBannerVariant.danger,
                              ),
                              SizedBox(height: spacing.s16),
                            ],
                            if (state.hasMoreResults) ...[
                              Text(
                                l10n.baseCurrencySettingsResultsHint,
                                style: typography.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              SizedBox(height: spacing.s12),
                            ],
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    radius.r12,
                                  ),
                                  border: Border.all(color: colors.border),
                                ),
                                child: _CurrencyList(
                                  currencies: visible,
                                  selectedCode: state.selectedCode,
                                  isAllowed: (code) =>
                                      _isAllowedByPlan(state.plan, code),
                                  onSelect: (code) => context
                                      .read<BaseCurrencySettingsCubit>()
                                      .selectCurrency(code),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.baseCurrencySettingsSave,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : () => context
                                .read<BaseCurrencySettingsCubit>()
                                .save(),
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
      'rate_limited' => l10n.errorRateLimited,
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'conflict' => l10n.errorConflict,
      _ => l10n.errorGeneric,
    };
  }

  bool _isAllowedByPlan(String? plan, String code) {
    final normalizedPlan = (plan ?? 'free').toLowerCase();
    if (normalizedPlan == 'paid') {
      return true;
    }
    return BaseCurrencySettingsCubit.freeAllowedCodes.contains(
      code.toUpperCase(),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  const _CurrencyList({
    required this.currencies,
    required this.selectedCode,
    required this.isAllowed,
    required this.onSelect,
  });

  final List<CurrencyEntity> currencies;
  final String? selectedCode;
  final bool Function(String code) isAllowed;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final popularSet = BaseCurrencySettingsCubit.popularCodes.toSet();

    final sectionBreakIndex = currencies.indexWhere(
      (c) => !popularSet.contains(c.code.toUpperCase()),
    );

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: currencies.length,
      separatorBuilder: (context, index) {
        final shouldBreak =
            sectionBreakIndex > 0 && index == sectionBreakIndex - 1;
        if (!shouldBreak) {
          return Divider(height: 1, thickness: 1, color: colors.border);
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: spacing.s8),
          color: colors.surfaceAlt,
          child: Divider(height: 1, thickness: 1, color: colors.border),
        );
      },
      itemBuilder: (context, index) {
        final currency = currencies[index];

        final code = currency.code.toUpperCase();
        final selected = code == selectedCode?.toUpperCase();
        final allowed = isAllowed(code);

        return _CurrencyRow(
          code: code,
          name: currency.name,
          symbol: currency.symbol,
          selected: selected,
          locked: !allowed,
          onTap: () => onSelect(code),
        );
      },
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.code,
    required this.name,
    required this.symbol,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String code;
  final String name;
  final String? symbol;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    final background = selected
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surface;

    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s12,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.s12,
                  vertical: spacing.s4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(context.dsRadius.r12),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  code,
                  style: typography.caption.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: typography.body.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (symbol != null && symbol!.trim().isNotEmpty) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        symbol!,
                        style: typography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.s12),
              if (locked)
                Icon(Icons.lock_outline, color: colors.textTertiary)
              else if (selected)
                Icon(Icons.check_circle, color: colors.primary)
              else
                Icon(Icons.radio_button_unchecked, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
