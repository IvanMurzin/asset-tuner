import 'package:flutter/material.dart';

class DSSectionTitle extends StatelessWidget {
  const DSSectionTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? Theme.of(context).textTheme.titleLarge);
  }
}
