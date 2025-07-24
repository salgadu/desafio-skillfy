import 'dart:ui' as ui;

import 'package:desafio_skillfy/app/core/constants/env.dart';
import 'package:desafio_skillfy/app/core/service/storage/i_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  ThemeMode _themeMode = ThemeMode.system;
  final IStorage storage;

  ThemeController(this.storage);

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode;

  Future<void> initializeTheme() async {
    try {
      final themeMode = await storage.getString(themeModeKey);
      if (themeMode == null || themeMode.isEmpty) {
        _themeMode = ThemeMode.system;
        _themeData = ThemeData.light();
      } else {
        if (themeMode == 'dark') {
          _themeMode = ThemeMode.dark;
          _themeData = ThemeData.dark();
        } else {
          _themeMode = ThemeMode.light;
          _themeData = ThemeData.light();
        }
      }
    } catch (e) {
      _themeMode = ThemeMode.system;
      _themeData = ThemeData.light();
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    try {
      if (_themeMode == ThemeMode.light) {
        await storage.saveString(themeModeKey, 'dark');
        _themeMode = ThemeMode.dark;
        _themeData = ThemeData.dark();
      } else {
        await storage.saveString(themeModeKey, 'light');
        _themeMode = ThemeMode.light;
        _themeData = ThemeData.light();
      }
      notifyListeners();
    } catch (e) {}
  }
}
