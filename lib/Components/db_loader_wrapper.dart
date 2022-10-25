import 'package:flutter/cupertino.dart';
import 'package:nz_ua/nzsiteapi/ISQLObject.dart';

class DatabaseLoaderWrapper<T> extends StatelessWidget {
  const DatabaseLoaderWrapper({
    Key? key,
    required this.onBuild,
    required this.parseCallback,
    required this.id,
  }) : super(key: key);

  final Callback onBuild;
  final JsonParseCallback parseCallback;
  final int id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context, snapshot) {
          var t;

          if (snapshot.hasData && snapshot.data != null) {
            try {
              t = parseCallback(snapshot.data as Map<String, dynamic>);
            } catch (e) {
              //
            }
          }

          return onBuild(t);
        },
        future: ISQLObject.getById<T>(id));
  }
}

typedef Callback = Widget Function(Object?);
typedef JsonParseCallback = Object Function(Map<String, dynamic>);
