import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _storageKey = 'appLanguage';
  static const Locale portuguese = Locale('pt');
  static const Locale english = Locale('en');

  static const List<Locale> supported = [portuguese, english];

  Locale _locale = portuguese;
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey) ?? 'pt';
    _locale = code == 'en' ? english : portuguese;
  }

  Future<void> setLocale(Locale value) async {
    if (value == _locale) return;
    _locale = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value.languageCode);
    notifyListeners();
  }

  String displayName(Locale l) {
    return l.languageCode == 'pt' ? 'Português' : 'English';
  }

  String flag(Locale l) {
    return l.languageCode == 'pt' ? '🇵🇹' : '🇬🇧';
  }
}
