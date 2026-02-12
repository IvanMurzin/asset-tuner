import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class DSCurrencyPickerOption {
  const DSCurrencyPickerOption({
    required this.id,
    required this.primaryText,
    this.secondaryText,
    this.tertiaryText,
    this.searchTerms = const [],
    this.locked = false,
  });

  final String id;
  final String primaryText;
  final String? secondaryText;
  final String? tertiaryText;
  final List<String> searchTerms;
  final bool locked;
}

class DSCurrencyPicker extends StatelessWidget {
  const DSCurrencyPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.searchHintText,
    required this.recentTitleText,
    required this.selectedTitleText,
    required this.changeSelectionText,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
    required this.onSelect,
    this.recentOptionIds = const [],
    this.maxRecent = 5,
    this.maxSearchResults = 50,
    this.enabled = true,
  });

  final List<DSCurrencyPickerOption> options;
  final String? selectedId;
  final String searchHintText;
  final String recentTitleText;
  final String selectedTitleText;
  final String changeSelectionText;
  final String emptyResultsTitle;
  final String emptyResultsMessage;
  final ValueChanged<String> onSelect;
  final List<String> recentOptionIds;
  final int maxRecent;
  final int maxSearchResults;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final selected = selectedId == null
        ? null
        : options.where((option) => option.id == selectedId).firstOrNull;

    return InkWell(
      borderRadius: BorderRadius.circular(context.dsRadius.r12),
      onTap: enabled ? () => _openSheet(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s12,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          color: enabled ? colors.surface : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(context.dsRadius.r12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.dsRadius.r8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.currency_exchange,
                color: colors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedTitleText,
                    style: typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.s4),
                  Text(
                    selected == null ? searchHintText : _displayTitle(selected),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.copyWith(
                      color: selected == null
                          ? colors.textTertiary
                          : colors.textPrimary,
                      fontWeight: selected == null
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.s8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? colors.textSecondary : colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        options: options,
        selectedId: selectedId,
        searchHintText: searchHintText,
        titleText: selectedTitleText,
        emptyResultsTitle: emptyResultsTitle,
        emptyResultsMessage: emptyResultsMessage,
      ),
    );

    if (selected == null || selected.isEmpty) {
      return;
    }
    onSelect(selected);
  }

  String _displayTitle(DSCurrencyPickerOption option) {
    if ((option.secondaryText ?? '').trim().isEmpty) {
      return option.primaryText;
    }
    return '${option.primaryText} · ${option.secondaryText!}';
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.options,
    required this.selectedId,
    required this.searchHintText,
    required this.titleText,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
  });

  final List<DSCurrencyPickerOption> options;
  final String? selectedId;
  final String searchHintText;
  final String titleText;
  final String emptyResultsTitle;
  final String emptyResultsMessage;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final filtered = _filteredOptions(widget.options, _queryController.text);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.84,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.dsRadius.r16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.s8),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: spacing.s12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.titleText, style: typography.h3),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s8,
                  spacing.s16,
                  spacing.s12,
                ),
                child: DSSearchField(
                  controller: _queryController,
                  hintText: widget.searchHintText,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s16,
                          ),
                          child: DSEmptyState(
                            title: widget.emptyResultsTitle,
                            message: widget.emptyResultsMessage,
                            icon: Icons.search_off_outlined,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          spacing.s16,
                          0,
                          spacing.s16,
                          spacing.s16,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: colors.border),
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          final isSelected = option.id == widget.selectedId;
                          return DSListRow(
                            title: _title(option),
                            subtitle: option.tertiaryText,
                            selected: isSelected,
                            trailing: option.locked
                                ? Icon(
                                    Icons.lock_outline,
                                    color: colors.textTertiary,
                                  )
                                : isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: colors.primary,
                                  )
                                : Icon(
                                    Icons.arrow_outward,
                                    color: colors.textTertiary,
                                    size: 18,
                                  ),
                            onTap: () => Navigator.of(context).pop(option.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DSCurrencyPickerOption> _filteredOptions(
    List<DSCurrencyPickerOption> source,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return source;
    }

    return source.where((option) {
      return option.primaryText.toLowerCase().contains(normalized) ||
          (option.secondaryText ?? '').toLowerCase().contains(normalized) ||
          (option.tertiaryText ?? '').toLowerCase().contains(normalized) ||
          option.searchTerms.any(
            (term) => term.toLowerCase().contains(normalized),
          );
    }).toList();
  }

  String _title(DSCurrencyPickerOption option) {
    if ((option.secondaryText ?? '').trim().isEmpty) {
      return option.primaryText;
    }
    return '${option.primaryText} · ${option.secondaryText!}';
  }
}
