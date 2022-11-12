import 'package:flutter/cupertino.dart';
import 'package:nz_ua/Components/database.dart';

class DatabaseLoaderWrapper<T> extends StatelessWidget {
  const DatabaseLoaderWrapper({
    Key? key,
    required this.onBuild,
    required this.parseCallback,
    required this.id,
  }) : super(key: key);

  final OnBuild onBuild;
  final JsonParseCallback parseCallback;
  final String id;

  @override
  Widget build(BuildContext context) {
    var v = Database.get(id);
    if (v == null) return onBuild(null);
    return onBuild(parseCallback(v));
  }
}

typedef OnBuild = Widget Function(Object?);
typedef JsonParseCallback = Object Function(Map<String, dynamic>);
