import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core_ui/components/ds_password_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_in_cubit.dart';

class SignInPasswordField extends StatefulWidget {
  const SignInPasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? errorText;

  @override
  State<SignInPasswordField> createState() => _SignInPasswordFieldState();
}

class _SignInPasswordFieldState extends State<SignInPasswordField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SignInCubit>().state;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;
    final isLoading = state.status == SignInStatus.loading;

    if (_controller.text != state.password) {
      _controller.text = state.password;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: typography.label),
        SizedBox(height: spacing.s8),
        DSPasswordField(
          label: null,
          hintText: widget.hint,
          controller: _controller,
          enabled: !isLoading,
          errorText: widget.errorText,
          onChanged: context.read<SignInCubit>().updatePassword,
        ),
      ],
    );
  }
}
