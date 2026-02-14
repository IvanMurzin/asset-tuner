import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/presentation/settings/widget/base_currency_settings_currency_row.dart';

class BaseCurrencySettingsCurrencyList extends StatelessWidget {
  const BaseCurrencySettingsCurrencyList({
    super.key,
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

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: currencies.length,
      separatorBuilder: (context, index) {
        return Divider(height: 1, thickness: 1, color: colors.border);
      },
      itemBuilder: (context, index) {
        final currency = currencies[index];

        final code = currency.code.toUpperCase();
        final selected = code == selectedCode?.toUpperCase();
        final allowed = isAllowed(code);

        return BaseCurrencySettingsCurrencyRow(
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
