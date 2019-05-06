import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// This is just a development prototype for locally storing consumables. Do not
// use this.
class ConsumableStore {
  static const String _kPrefKey = 'consumables';
  static Future<void> _writing = Future.value();

  static Future<void> save(String id) async {
    Completer writingCompleter = Completer();
    await _writing;
    _writing = writingCompleter.future;
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.add(id);
    await prefs.setStringList(_kPrefKey, cached);
    writingCompleter.complete();
  }

  static Future<void> consume(String id) async {
    Completer writingCompleter = Completer();
    await _writing;
    _writing = writingCompleter.future;
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.remove(id);
    await prefs.setStringList(_kPrefKey, cached);
    writingCompleter.complete();
  }

  static Future<List<String>> load() async {
    return (await SharedPreferences.getInstance()).getStringList(_kPrefKey) ??
        [];
  }
}
