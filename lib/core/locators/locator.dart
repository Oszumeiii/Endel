import 'package:auto_route/auto_route.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../services/switch_theme/switch_theme_cubit.dart';
import '../app/app_router.dart';
import '../language/lang_cubit.dart';
import 'di/getit_utils.dart';

// ===== Instances: Navigation =====
/// [AppRouter] instance for managing app navigation
final router = getIt<AppRouter>();

/// [AutoRouteObserver] instance for observing route changes
final autoRouteObserver = getIt<AutoRouteObserver>();

// ===== Instances: Cubit/Bloc =====
final themeCubit = getIt<SwitchThemeCubit>();
final langCubit = getIt<LangCubit>();

// ===== Instances: Logging =====
/// [Talker] instance for logging and debugging
final talker = getIt<Talker>();
