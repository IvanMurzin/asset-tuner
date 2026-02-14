import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSBaseCurrencyValueCard extends StatelessWidget {
  const DSBaseCurrencyValueCard({
    super.key,
    required this.title,
    required this.caption,
    required this.currencyCode,
    this.codeFallback = '—',
  });

  final String title;
  final String caption;
  final String? currencyCode;
  final String codeFallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return DSCard(
      padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(radius.r12),
            ),
            child: Icon(Icons.currency_exchange_rounded, color: colors.primary, size: 20),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Text(
              caption,
              style: typography.body.copyWith(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: spacing.s32),
          Text(
            (currencyCode ?? codeFallback).toUpperCase(),
            style: typography.h2.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: spacing.s8),
        ],
      ),
    );
  }
}
