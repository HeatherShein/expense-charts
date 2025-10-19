import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  static const String keyVariableName = 'remaining_budget';

  static Future<SharedPreferences>? _prefsInstance;

  static Future<SharedPreferences> getInstance() async {
    _prefsInstance ??= SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  static Future<void> saveVariable(double value) async {
    final prefs = await getInstance();
    await prefs.setDouble(keyVariableName, value);
  }

  static Future<double> getVariable() async {
    final prefs = await getInstance();
    return prefs.getDouble(keyVariableName) ?? 0.0;
  }

  static Future<void> clearVariable() async {
    final prefs = await getInstance();
    await prefs.remove(keyVariableName);
  }
}