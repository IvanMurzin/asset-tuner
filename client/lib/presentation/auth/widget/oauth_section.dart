import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core_ui/components/ds_oauth_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_in_cubit.dart';

class OAuthSection extends StatelessWidget {
  const OAuthSection({
    super.key,
    required this.isLoading,
    required this.providers,
    required this.googleLabel,
    required this.appleLabel,
  });

  final bool isLoading;
  final List<AuthProvider> providers;
  final String googleLabel;
  final String appleLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final buttons = <Widget>[];
    for (final provider in providers) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(height: spacing.s12));
      }
      buttons.add(
        DSOAuthButton(
          provider: _mapProvider(provider),
          label: _labelFor(provider),
          onPressed: isLoading
              ? null
              : () => context.read<SignInCubit>().signInWithProvider(provider),
        ),
      );
    }

    return Column(children: buttons);
  }

  DSOAuthProvider _mapProvider(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => DSOAuthProvider.google,
      AuthProvider.apple => DSOAuthProvider.apple,
      AuthProvider.email => DSOAuthProvider.google,
    };
  }

  String _labelFor(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => googleLabel,
      AuthProvider.apple => appleLabel,
      AuthProvider.email => googleLabel,
    };
  }
}
