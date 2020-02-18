import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  final SharedPreferences _pref;

  PreferenceManager(this._pref);

  String load(String book) => _pref.getString(book);
  void save(String book, String chapter) => _pref.setString(book, chapter);
  void remove(String book) => _pref.remove(book);
}