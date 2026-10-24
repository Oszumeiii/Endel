// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i790;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:rvc_mobile_application/core/app/app_module.dart' as _i773;
import 'package:rvc_mobile_application/core/app/app_router.dart' as _i742;
import 'package:rvc_mobile_application/core/language/lang_cubit.dart' as _i390;
import 'package:rvc_mobile_application/core/language/lang_repository.dart'
    as _i914;
import 'package:rvc_mobile_application/core/language/lang_repository_interface.dart'
    as _i964;
import 'package:rvc_mobile_application/core/services/network/network_cubit.dart'
    as _i808;
import 'package:rvc_mobile_application/core/services/switch_theme/switch_theme_cubit.dart'
    as _i1002;
import 'package:rvc_mobile_application/core/utils/logger.dart' as _i1021;
import 'package:rvc_mobile_application/data/local/hive/hive_util.dart' as _i171;
import 'package:talker_flutter/talker_flutter.dart' as _i207;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final loggerModule = _$LoggerModule();
    final appModule = _$AppModule();
    gh.singleton<_i742.AppRouter>(() => _i742.AppRouter());
    gh.singleton<_i808.NetworkCubit>(() => _i808.NetworkCubit());
    gh.singleton<_i1002.SwitchThemeCubit>(() => _i1002.SwitchThemeCubit());
    gh.singleton<_i207.Talker>(() => loggerModule.talker());
    gh.singleton<_i171.HiveUtils>(() => _i171.HiveUtils());
    gh.lazySingleton<_i790.AutoRouteObserver>(
      () => appModule.autoRouteObserver,
    );
    gh.lazySingleton<_i964.ILangRepository>(() => _i914.LangRepository());
    gh.singleton<_i390.LangCubit>(
      () => _i390.LangCubit(gh<_i964.ILangRepository>()),
    );
    return this;
  }
}

class _$LoggerModule extends _i1021.LoggerModule {}

class _$AppModule extends _i773.AppModule {}
