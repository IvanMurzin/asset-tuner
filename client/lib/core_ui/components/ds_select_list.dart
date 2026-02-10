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
    this.shrinkWrap = false,
    this.physics,
  });

  final List<DSSelectOption> options;
  final String? selectedId;
  final ValueChanged<DSSelectOption> onSelect;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

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
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return _DSSelectListItem(
            option: option,
            selected: option.id == selectedId,
            onTap: () => onSelect(option),
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1, thickness: 1, color: colors.border),
      ),
    );
  }
}

class _DSSelectListItem extends StatelessWidget {
  const _DSSelectListItem({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DSSelectOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DSRadioRow(
      title: option.title,
      subtitle: option.subtitle,
      selected: selected,
      onTap: onTap,
    );
  }
}
