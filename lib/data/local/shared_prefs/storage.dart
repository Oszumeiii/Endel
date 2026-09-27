import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../modules/profile/models/user_model.dart';

class _Keys {
  static const lang = 'lang';
  static const user = 'user';
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const deviceId = 'device_id';
  static const pushToken = 'push_token';
  static const apnsToken = 'apns_token';
  static const rememberMe = 'remember_me';
  static const themeMode = 'theme_mode';
  static const notificationManualDisabled = 'notification_manual_disabled';
  static const appLaunchCount = 'app_launch_count';
  static const deviceName = 'device_name';
  static const userDefault = 'user_default';
}

class Storage {
  static late final SharedPreferences _preferences;

  static late final RxSharedPreferences _rxPreferences;

  static const _storage = FlutterSecureStorage();

  static Future<void> setup() async {
    _preferences = await SharedPreferences.getInstance();

    _rxPreferences = RxSharedPreferences(
      _preferences,

      kReleaseMode ? null : const RxSharedPreferencesDefaultLogger(),
    );
  }

  static T? _get<T>(String key) => _preferences.get(key) as T?;

  static Future<void> _set<T>(String key, T? val, {bool notify = false}) {
    if (val == null) {
      return notify ? _rxPreferences.remove(key) : _preferences.remove(key);
    }
    if (val is bool) {
      return notify
          ? _rxPreferences.setBool(key, val)
          : _preferences.setBool(key, val);
    }
    if (val is double) {
      return notify
          ? _rxPreferences.setDouble(key, val)
          : _preferences.setDouble(key, val);
    }
    if (val is int) {
      return notify
          ? _rxPreferences.setInt(key, val)
          : _preferences.setInt(key, val);
    }
    if (val is String) {
      return notify
          ? _rxPreferences.setString(key, val)
          : _preferences.setString(key, val);
    }
    if (val is List<String>) {
      notify
          ? _rxPreferences.setStringList(key, val)
          : _preferences.setStringList(key, val);
    }
    throw Exception('Type not supported!');
  }

  static Future<String?> _getSecure(String key) => _storage.read(key: key);

  static Future<void> _setSecure(String key, String? val) =>
      _storage.write(key: key, value: val);

  static Future<void> setAccessToken(String? accessToken) async {
    await _setSecure(_Keys.accessToken, accessToken);
  }

  static Future<String?> getAccessToken() async {
    return _getSecure(_Keys.accessToken);
  }

  static Future<void> setRefreshToken(String? refreshToken) async {
    await _setSecure(_Keys.refreshToken, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return _getSecure(_Keys.refreshToken);
  }

  static String? get lang => _get(_Keys.lang);

  static Future setLang(String? val) => _set(_Keys.lang, val);

  static String get deviceId {
    String? deviceId = _get(_Keys.deviceId);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      setDeviceId(deviceId);
    }
    return deviceId;
  }

  static Future setDeviceId(String? val) => _set(_Keys.deviceId, val);

  static String? get pushToken => _get(_Keys.pushToken);

  static Future setPushToken(String? val) => _set(_Keys.pushToken, val);

  static String? get apnsToken => _get(_Keys.apnsToken);

  static Future setApnsToken(String? val) => _set(_Keys.apnsToken, val);

  static Future<void> setRememberMe(bool rememberMe) async {
    await _set(_Keys.rememberMe, rememberMe);
  }

  static bool get rememberMe => _get<bool>(_Keys.rememberMe) ?? false;

  static Future<void> setThemeMode(int themeMode) async {
    await _set(_Keys.themeMode, themeMode);
  }

  static int get themeMode => _get<int>(_Keys.themeMode) ?? 1;

  static Future<void> setNotificationManualDisabled(bool val) async {
    await _set(_Keys.notificationManualDisabled, val);
  }

  static bool get notificationManualDisabled =>
      _get<bool>(_Keys.notificationManualDisabled) ?? false;

  // App launch counter getters and setters
  static int get appLaunchCount => _get<int>(_Keys.appLaunchCount) ?? 0;

  static Future<void> setAppLaunchCount(int val) =>
      _set(_Keys.appLaunchCount, val);

  static Future<void> incrementAppLaunchCount() async {
    int currentCount = appLaunchCount;
    await setAppLaunchCount(currentCount + 1);
  }

  static bool get isSecondLaunch => appLaunchCount == 2;

  // Lưu thông tin người dùng vào SharedPreferences
  static Future<void> setUser(UserModel user) async {
    final jsonUser = jsonEncode(user.toJson()); // Chuyển UserModel thành JSON
    await _set(_Keys.user, jsonUser); // Lưu JSON vào SharedPreferences
  }

  // Truy xuất thông tin người dùng từ SharedPreferences
  static UserModel? get user {
    final jsonString = _get<String>(
      _Keys.user,
    ); // Lấy JSON từ SharedPreferences
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(
        jsonDecode(jsonString),
      ); // Chuyển JSON thành UserModel
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearInfoUser() async {
    // Xóa thông tin người dùng
    await _preferences.remove(_Keys.user);

    // Xóa accessToken và refreshToken
    await _storage.delete(key: _Keys.accessToken);
    await _storage.delete(key: _Keys.refreshToken);
  }

  static bool get isLoggedIn => user != null;

  static String? get deviceName => _get(_Keys.deviceName);

  static Future<void> setDeviceName(String? val) => _set(_Keys.deviceName, val);

  // Truy xuất thông tin người dùng mặc định từ SharedPreferences
  static UserModel? get userDefault {
    final jsonString = _get<String>(
      _Keys.userDefault,
    ); // Lấy JSON từ SharedPreferences
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(
        jsonDecode(jsonString),
      ); // Chuyển JSON thành UserModel
    } catch (e) {
      return null;
    }
  }

  // Lưu thông tin người dùng mặc định vào SharedPreferences
  static Future<void> setUserDefault(UserModel user) async {
    final jsonUser = jsonEncode(user.toJson()); // Chuyển UserModel thành JSON
    await _set(_Keys.userDefault, jsonUser); // Lưu JSON vào SharedPreferences
  }
}
