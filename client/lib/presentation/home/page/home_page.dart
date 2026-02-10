import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: DSAppBar(title: l10n.homeTitle),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.s24),
          child: DSButton(
            label: l10n.designSystemPreview,
            onPressed: () => context.go(AppRoutes.designSystem),
          ),
        ),
      ),
    );
  }
}
