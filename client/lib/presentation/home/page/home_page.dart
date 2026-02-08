import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/routing/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(AppRoutes.designSystem),
          child: const Text('Design system preview'),
        ),
      ),
    );
  }
}
