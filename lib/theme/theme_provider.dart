import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passwordmanager/theme/themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkTheme();
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  Future<void> toggleThemeWithDelay() async {
    // Introduce a delay of 200 milliseconds (adjust as needed)
    await Future.delayed(const Duration(milliseconds: 200));

    toggleTheme();
  }

  void toggleTheme() {
    if (_themeData == lightTheme()) {
      themeData = darkTheme();
    } else {
      themeData = lightTheme();
    }
  }
}
