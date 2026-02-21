import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';

class AccountActionsPage extends StatelessWidget {
  const AccountActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == UserStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: Scaffold(
        appBar: DSAppBar(title: l10n.profileSectionAccount),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dsSpacing.s24),
            child: ListView(
              children: [
                DSSectionTitle(title: l10n.settingsSignOut),
                SizedBox(height: context.dsSpacing.s12),
                DSCard(
                  child: DSButton(
                    label: l10n.settingsSignOut,
                    variant: DSButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: context.read<UserCubit>().logoutOptimistic,
                  ),
                ),
                SizedBox(height: context.dsSpacing.s24),
                DSSectionTitle(title: l10n.profileDeleteAccountTitle),
                SizedBox(height: context.dsSpacing.s12),
                DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileDeleteAccountBody,
                        style: context.dsTypography.body.copyWith(
                          color: context.dsColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: context.dsSpacing.s16),
                      DSButton(
                        label: l10n.profileDeleteAccountCta,
                        variant: DSButtonVariant.danger,
                        fullWidth: true,
                        onPressed: () => _confirmDelete(context, l10n),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.profileDeleteConfirmTitle,
        content: Text(l10n.profileDeleteConfirmBody),
        primaryLabel: l10n.profileDeleteConfirmCta,
        secondaryLabel: l10n.profileDeleteConfirmCancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<UserCubit>().deleteAccountOptimistic();
    }
  }
}
