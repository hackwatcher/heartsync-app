import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  SharedPreferences? _prefs;
  String _prefix = '';

  void setPrefix(String prefix) {
    _prefix = prefix;
  }

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveString(String key, String value) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(_prefix + key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getString(_prefix + key);
  }

  Future<void> saveObject(String key, dynamic object) async {
    await saveString(key, jsonEncode(object));
  }

  Future<dynamic> getObject(String key) async {
    final s = await getString(key);
    return s != null ? jsonDecode(s) : null;
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await _sharedPrefs;
    await prefs.setBool(_prefix + key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(_prefix + key);
  }

  Future<void> remove(String key) async {
    final prefs = await _sharedPrefs;
    await prefs.remove(_prefix + key);
  }

  Future<void> clearAll() async {
    final prefs = await _sharedPrefs;
    await prefs.clear();
  }
}
