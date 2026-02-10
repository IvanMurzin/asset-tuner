import 'package:go_router/go_router.dart';
import 'package:template/core/routing/app_routes.dart';
import 'package:template/core_ui/preview/ds_preview_page.dart';
import 'package:template/presentation/home/page/home_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.designSystem,
      builder: (context, state) => const DSPreviewPage(),
    ),
  ],
);
