import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../modules/main/screen/main_screen.dart';

import 'route_path.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig(
  replaceInRouteName: 'Screen|Page,Route',
) //HomePage -> HomeRoute
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      path: Routers.mainScreen,
      initial: true,
    ),
  ];
}
