import 'dart:convert';

import 'package:prefs/prefs.dart';

class Database {
  static Map<String, dynamic>? get(String id) {
    var s = Prefs.getString(id);
    if(s.isEmpty) return null;
    return json.decode(s);
  }

  static void save(Object obj, String id) {
    Prefs.setString(id, json.encode(obj));
  }
}