import 'package:flutter/material.dart';
import 'package:map_test/src/injection.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController();

  final _settingsService = locator<SettingsService>();

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }
}
