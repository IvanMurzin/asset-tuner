import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContactDeveloperPage extends StatefulWidget {
  const ContactDeveloperPage({super.key, IProfileRepository? repository})
    : _repository = repository;

  final IProfileRepository? _repository;

  @override
  State<ContactDeveloperPage> createState() => _ContactDeveloperPageState();
}

class _ContactDeveloperPageState extends State<ContactDeveloperPage> {
  late final IProfileRepository _repository;
  late final TextEditingController _emailController;
  late final TextEditingController _messageController;

  bool _isSubmitting = false;
  String? _messageErrorText;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? getIt<IProfileRepository>();
    final session = context.read<SessionCubit>().state.session;
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
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SessionStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          if (!sessionState.isAuthenticated || sessionState.session == null) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.profileContactDeveloperTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.go(AppRoutes.signIn),
              ),
            );
          }
          return Scaffold(
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
                              enabled: !_isSubmitting,
                              errorText: _messageErrorText,
                              onChanged: (_) {
                                if (_messageErrorText == null) {
                                  return;
                                }
                                setState(() => _messageErrorText = null);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.dsSpacing.s16),
                    DSButton(
                      label: l10n.profileContactDeveloperSubmitCta,
                      fullWidth: true,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting
                          ? null
                          : () => _submit(session: sessionState.session!, l10n: l10n),
                    ),
                    SizedBox(height: context.dsSpacing.s12),
                    DSButton(
                      label: l10n.cancel,
                      fullWidth: true,
                      variant: DSButtonVariant.secondary,
                      onPressed: _isSubmitting ? null : () => context.pop(),
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

  Future<void> _submit({required AuthSessionEntity session, required AppLocalizations l10n}) async {
    final description = _messageController.text.trim();
    if (description.isEmpty) {
      setState(() => _messageErrorText = l10n.profileContactDeveloperMessageRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _messageErrorText = null;
    });

    final result = await _repository.sendContactDeveloperMessage(
      name: _resolveName(session),
      email: session.email,
      description: description,
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<void>():
        context.pop(true);
      case FailureResult<void>(failure: final failure):
        logger.e('Contact developer submit failed: ${failure.code}');
        setState(() => _isSubmitting = false);
        showDSSnackBar(context, variant: DSSnackBarVariant.error, message: failure.message);
    }
  }

  String _resolveName(AuthSessionEntity session) {
    final trimmed = session.email.trim();
    if (trimmed.isEmpty) {
      return session.userId;
    }
    final marker = trimmed.indexOf('@');
    if (marker <= 0) {
      return trimmed;
    }
    return trimmed.substring(0, marker);
  }
}
