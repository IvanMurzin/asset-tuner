import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_radio_row.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSelectOption {
  const DSSelectOption({required this.id, required this.title, this.subtitle});

  final String id;
  final String title;
  final String? subtitle;
}

class DSSelectList extends StatelessWidget {
  const DSSelectList({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  final List<DSSelectOption> options;
  final String? selectedId;
  final ValueChanged<DSSelectOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    final colors = context.dsColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: options
            .map(
              (option) => _DSSelectListItem(
                option: option,
                selected: option.id == selectedId,
                showDivider: option != options.last,
                onTap: () => onSelect(option),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DSSelectListItem extends StatelessWidget {
  const _DSSelectListItem({
    required this.option,
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  final DSSelectOption option;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;

    return Column(
      children: [
        DSRadioRow(
          title: option.title,
          subtitle: option.subtitle,
          selected: selected,
          onTap: onTap,
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: colors.border),
      ],
    );
  }
}
