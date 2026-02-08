import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template/core_ui/components/button/ds_button.dart';
import 'package:template/core_ui/components/card/ds_card.dart';
import 'package:template/core_ui/components/text_field/ds_text_field.dart';
import 'package:template/core_ui/components/typography/ds_section_title.dart';
import 'package:template/core_ui/theme/theme_mode_cubit.dart';
import 'package:template/core_ui/tokens/ds_spacing.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Preview')),
      body: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, mode) {
          final textTheme = Theme.of(context).textTheme;

          return ListView(
            padding: DSSpacing.page,
            children: [
              const DSSectionTitle('Theme'),
              const SizedBox(height: DSSpacing.s12),
              DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: DSSpacing.s8,
                      runSpacing: DSSpacing.s8,
                      children: [
                        DSButton(
                          label: 'System',
                          variant: mode == ThemeMode.system
                              ? DSButtonVariant.primary
                              : DSButtonVariant.secondary,
                          onPressed: () => context.read<ThemeModeCubit>().set(
                            ThemeMode.system,
                          ),
                        ),
                        DSButton(
                          label: 'Light',
                          variant: mode == ThemeMode.light
                              ? DSButtonVariant.primary
                              : DSButtonVariant.secondary,
                          onPressed: () => context.read<ThemeModeCubit>().set(
                            ThemeMode.light,
                          ),
                        ),
                        DSButton(
                          label: 'Dark',
                          variant: mode == ThemeMode.dark
                              ? DSButtonVariant.primary
                              : DSButtonVariant.secondary,
                          onPressed: () => context.read<ThemeModeCubit>().set(
                            ThemeMode.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.s12),
                    DSButton(
                      label: 'Toggle light/dark',
                      variant: DSButtonVariant.text,
                      onPressed: () => context.read<ThemeModeCubit>().toggle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.s24),
              const DSSectionTitle('Typography'),
              const SizedBox(height: DSSpacing.s12),
              DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display', style: textTheme.displayLarge),
                    const SizedBox(height: DSSpacing.s8),
                    Text('Headline', style: textTheme.headlineMedium),
                    const SizedBox(height: DSSpacing.s8),
                    Text('Title', style: textTheme.titleLarge),
                    const SizedBox(height: DSSpacing.s8),
                    Text('Body', style: textTheme.bodyLarge),
                    const SizedBox(height: DSSpacing.s8),
                    Text('Label', style: textTheme.labelLarge),
                    const SizedBox(height: DSSpacing.s8),
                    Text('Caption', style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.s24),
              const DSSectionTitle('Buttons'),
              const SizedBox(height: DSSpacing.s12),
              DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: DSSpacing.s8,
                      runSpacing: DSSpacing.s8,
                      children: [
                        DSButton(label: 'Primary', onPressed: () {}),
                        DSButton(
                          label: 'Secondary',
                          variant: DSButtonVariant.secondary,
                          onPressed: () {},
                        ),
                        DSButton(
                          label: 'Text',
                          variant: DSButtonVariant.text,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.s12),
                    Wrap(
                      spacing: DSSpacing.s8,
                      runSpacing: DSSpacing.s8,
                      children: [
                        const DSButton(label: 'Disabled', onPressed: null),
                        const DSButton(
                          label: 'Loading',
                          isLoading: true,
                          onPressed: null,
                        ),
                        DSButton(
                          label: 'With icon',
                          icon: Icons.pets,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.s12),
                    DSButton(
                      label: 'Full width',
                      fullWidth: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.s24),
              const DSSectionTitle('Text fields'),
              const SizedBox(height: DSSpacing.s12),
              DSCard(
                child: Column(
                  children: const [
                    DSTextField(
                      label: 'Email',
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    SizedBox(height: DSSpacing.s12),
                    DSTextField(
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    SizedBox(height: DSSpacing.s12),
                    DSTextField(
                      label: 'With error',
                      hint: 'Try again',
                      errorText: 'Invalid value',
                      prefixIcon: Icons.error_outline,
                    ),
                    SizedBox(height: DSSpacing.s12),
                    DSTextField(
                      label: 'Disabled',
                      hint: 'Disabled',
                      enabled: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.s24),
              const DSSectionTitle('Cards'),
              const SizedBox(height: DSSpacing.s12),
              DSCard(
                header: Text('Card header', style: textTheme.titleLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A minimal surface container with padding, border, and rounded corners.',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: DSSpacing.s12),
                    Wrap(
                      spacing: DSSpacing.s8,
                      runSpacing: DSSpacing.s8,
                      children: [
                        DSButton(
                          label: 'Action',
                          variant: DSButtonVariant.secondary,
                          onPressed: () {},
                        ),
                        DSButton(
                          label: 'Secondary',
                          variant: DSButtonVariant.text,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
