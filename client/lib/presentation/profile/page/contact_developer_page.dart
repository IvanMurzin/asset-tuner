import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/contact_developer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContactDeveloperPage extends StatelessWidget {
  const ContactDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactDeveloperCubit>(),
      child: const _ContactDeveloperView(),
    );
  }
}

class _ContactDeveloperView extends StatefulWidget {
  const _ContactDeveloperView();

  @override
  State<_ContactDeveloperView> createState() => _ContactDeveloperViewState();
}

class _ContactDeveloperViewState extends State<_ContactDeveloperView> {
  late final TextEditingController _emailController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthCubit>().state.session;
    _emailController = TextEditingController(text: session?.email ?? '');
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = context.watch<AuthCubit>().state.session;
    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final cubit = context.read<ContactDeveloperCubit>();
    final state = context.watch<ContactDeveloperCubit>().state;
    final isSubmitting = state.status != ContactDeveloperStatus.idle;

    return MultiBlocListener(
      listeners: [
        BlocListener<ContactDeveloperCubit, ContactDeveloperState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status && curr.status == ContactDeveloperStatus.sent,
          listener: (context, _) => context.pop(true),
        ),
        BlocListener<ContactDeveloperCubit, ContactDeveloperState>(
          listenWhen: (prev, curr) =>
              prev.failureCode != curr.failureCode && curr.failureCode != null,
          listener: (context, state) => showDSSnackBar(
            context,
            variant: DSSnackBarVariant.error,
            message: state.failureMessage ?? l10n.errorGeneric,
          ),
        ),
      ],
      child: Scaffold(
        appBar: DSAppBar(title: l10n.profileContactDeveloperTitle),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dsSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileContactDeveloperDescription,
                          style: context.dsTypography.body.copyWith(
                            color: context.dsColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.dsSpacing.s16),
                        DSTextField(
                          label: l10n.profileContactDeveloperEmailLabel,
                          controller: _emailController,
                          enabled: false,
                          readOnly: true,
                        ),
                        SizedBox(height: context.dsSpacing.s16),
                        DSTextField(
                          label: l10n.profileContactDeveloperMessageLabel,
                          hintText: l10n.profileContactDeveloperMessageHint,
                          controller: _messageController,
                          maxLines: 6,
                          enabled: !isSubmitting,
                          errorText: state.messageMissing
                              ? l10n.profileContactDeveloperMessageRequired
                              : null,
                          onChanged: (_) => cubit.messageChanged(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.dsSpacing.s16),
                DSButton(
                  label: l10n.profileContactDeveloperSubmitCta,
                  fullWidth: true,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () => cubit.submit(session: session, message: _messageController.text),
                ),
                SizedBox(height: context.dsSpacing.s12),
                DSButton(
                  label: l10n.cancel,
                  fullWidth: true,
                  variant: DSButtonVariant.secondary,
                  onPressed: isSubmitting ? null : () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
