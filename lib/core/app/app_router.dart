import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../modules/home/page/home_page.dart';
import '../../modules/profile/pages/profile_page.dart';
import '../../modules/settings/screen/settings_screen.dart';

import '../../modules/splash/presentation/splash_screen.dart';
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
    CustomRoute(
      page: SplashRoute.page,
      path: Routers.splashScreen,
      transitionsBuilder:
          TransitionsBuilders.fadeIn, // Sử dụng hiệu ứng fade-in
      duration: Duration(milliseconds: 500), // Thời gian chuyển cảnh
    ), // Màn hình splash đầu tiên

    AutoRoute(
      page: MainRoute.page,
      path: Routers.mainScreen,
      children: [
        AutoRoute(page: HomeRoute.page, path: Routers.homePage),
        AutoRoute(page: ProfileRoute.page, path: Routers.profilePage),
      ],
    ),

    AutoRoute(page: SettingsRoute.page, path: Routers.settingsScreen),
  ];
}
