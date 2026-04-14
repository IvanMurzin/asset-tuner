import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DSAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DSAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  State<DSAppBar> createState() => _DSAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DSAppBarState extends State<DSAppBar> {
  bool? _canPop;
  bool _scheduleDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scheduleDone) {
      _scheduleDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final canPop = Navigator.canPop(context) || GoRouter.of(context).canPop();
        if (_canPop != canPop) {
          setState(() => _canPop = canPop);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final canPop = _canPop ?? false;
    final effectiveLeading = widget.leading ?? (canPop ? BackButton(onPressed: context.pop) : null);

    return AppBar(
      title: Text(widget.title, style: typography.h2.copyWith(color: colors.textPrimary)),
      backgroundColor: colors.background,
      leading: effectiveLeading,
      automaticallyImplyLeading: effectiveLeading == null,
      foregroundColor: colors.textPrimary,
      centerTitle: widget.centerTitle,
      actions: widget.actions,
      elevation: 0,
    );
  }
}
