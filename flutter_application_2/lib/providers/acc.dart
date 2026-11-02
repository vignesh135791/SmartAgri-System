import 'package:flutter/material.dart';

enum TtsLanguage { tamil, english }

class AccessibilityProvider extends ChangeNotifier {
  TtsLanguage _language = TtsLanguage.tamil;
  int _currentScreen = 0;

  TtsLanguage get language => _language;
  int get currentScreen => _currentScreen;

  void toggleLanguage() {
    _language =
        _language == TtsLanguage.tamil ? TtsLanguage.english : TtsLanguage.tamil;
    notifyListeners();
  }

  void updateScreen(int index) {
    _currentScreen = index;
    notifyListeners();
  }
}
