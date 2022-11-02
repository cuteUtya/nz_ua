import 'package:nz_ua/nzsiteapi/nz_db.dart';

class ISQLObject<T> {
  ISQLObject({
    required this.schema,
  });

  Map<String, Type> schema;

  String get TEXT => "TEXT";
  String get DOUBLE => "DOUBLE";
  String get SQL_OBJECT => "SQL_OBJECT";
  String get INTEGER => "INTEGER";
  String get BOOLEAN => "BOOLEAN";
  String get DATETIME => "DATETIME";
  String get LIST => "LIST";

  get _fields => (_object as dynamic).toJson();
  get _object => this as T;
  get dbTableName => ISQLObject.getNameOfDB(type: (this as T).runtimeType);

  static String getNameOfDB<T>({Type? type}) {
    return type == null ? T.toString() : type.toString();
  }

  static String getNameOfChildDB(String defTableName) {
    return '${defTableName}_childdb';
  }

  Future deleteAllValues() async {
    try {
      nzdb.execute('DROP TABLE IF EXISTS $dbTableName');
    } catch (e) {
      // nothing
    }
  }

  Future<int> saveAsChild(String childOf) async {
    var name = getNameOfChildDB(dbTableName);
    if (!await tableIsExists(name)) {
      createTable(schema, isChild: true, name: name);
    }

    await this.save(tableName: name);

    return await _getLastInsertRowID();
  }

  Future<int> _getLastInsertRowID() async {
    var i = (await nzdb.rawQuery('SELECT last_insert_rowid();'))[0];
    return int.parse(i['last_insert_rowid()'].toString());
  }

  static Future<Map<String, dynamic>?> getByIdTableName(
      int id, String tableName) async {
    try {
      var query = 'SELECT * FROM $tableName WHERE DB_ID == $id';
      var r = await nzdb.rawQuery(query);

      var obj = await _deserializeSQLObject(r[0]);

      return obj;
    }catch(e) {
      // just returns null
    }
  }

  static Future<Map<String, dynamic>?> getById<T>(int id,
      {bool isChild = false}) async {
    assert(id >= 1);
    var name = ISQLObject.getNameOfDB<T>();
    if (isChild) name = ISQLObject.getNameOfChildDB(name);

    return getByIdTableName(id, name);
  }

  static Future<Map<String, dynamic>?> _deserializeSQLObject<T>(
      Map<String, Object?> s) async {
    Map<String, dynamic> jsonMap = {};

    var objectRegex = RegExp(r'\$object_link\$=\((\d*)\:(.*)\)');
    var arrayRegex = RegExp(r'\$arr_link\$=\((.*),(\d*):(\d*)\)');
    var booleanRegex = RegExp(r'\$bool_value\$:(.*)');

    var mKey = s.keys.toList();
    var mValues = s.values.toList();

    for (var j = 0; j < s.length; j++) {
      var key = mKey[j];
      var value = mValues[j];

      var val;
      if (value is String) {
        if (objectRegex.hasMatch(value)) {
          var regResult = objectRegex.firstMatch(value)!;
          var i = int.parse(regResult.group(1)!);
          var n = regResult.group(2)!;
          val = await ISQLObject.getByIdTableName(i, n);
          //this is object
        } else if (arrayRegex.hasMatch(value)) {
          List<dynamic> arr = [];

          var regResult = arrayRegex.firstMatch(value)!;
          var n = regResult.group(1)!;

          if (n != "__empty__") {
            var from = int.parse(regResult.group(2)!);
            var to = int.parse(regResult.group(3)!);

            for (var index = from; index <= to; index++) {
              arr.add(await ISQLObject.getByIdTableName(index, n));
            }
          }
          val = arr;
        } else if (booleanRegex.hasMatch(value)) {
          var l = booleanRegex.firstMatch(value)!.group(1)!;
          val = l == "true" || l == "True";
        }
      }

      val ??= value;

      jsonMap[key] = val;
    }

    return jsonMap;
  }

  Future<int> save({String? tableName}) async {
    var fields = _fields;

    if (!await tableIsExists(dbTableName)) {
      createTable(schema);
    }

    String getFields() {
      var s = '';
      schema.forEach((key, value) {
        s += "$key, ";
      });
      s = s.substring(0, s.length - 2);
      return s;
    }

    var query =
        'INSERT INTO ${tableName ?? dbTableName} (${getFields()})\nVALUES (';
    var kList = schema.keys.toList();
    var vList = schema.values.toList();
    for (var i = 0; i < schema.length; i++) {
      var key = kList[i];
      var value = vList[i];

      var t = getFieldType(value);
      var val = fields[key];
      if (val == null) {
        query += "NULL";
      } else {
        if (t != LIST && t != SQL_OBJECT && t != BOOLEAN) {
          if (t == TEXT) {
            query += "'${val.toString()}'";
          } else if (t == DATETIME) {
            query += "${(val as DateTime)}";
          } else {
            query += "$val";
          }
        } else {
          if (t == SQL_OBJECT) {
            ISQLObject sqlObject = val as ISQLObject;
            var tableN = getNameOfChildDB(sqlObject.dbTableName);
            var id = await sqlObject.saveAsChild(T.runtimeType.toString());
            query += "'\$object_link\$=($id:$tableN)'";
          } else if (t == LIST) {
            //check if arr.length == 0
            var from = 0;
            var valList = val as List;
            if (valList.isEmpty) {
              query += "'\$arr_link\$=(__empty__,0:0)'";
            } else {
              var tableN =
                  getNameOfChildDB((valList[0] as ISQLObject).dbTableName);
              for (var e in valList) {
                ISQLObject sq = e as ISQLObject;
                var id = await sq.saveAsChild(T.runtimeType.toString());
                if (valList.indexOf(e) == 0) {
                  from = id;
                }
              }
              query +=
                  "'\$arr_link\$=($tableN,$from:${from + valList.length - 1})'";
            }
          } else if (t == BOOLEAN) {
            query += "'\$bool_value\$:${val.toString()}'";
          }
        }
      }

      query += ", ";
    }

    query = query.substring(0, query.length - 2);

    query += ')';

    await nzdb.execute(query);

    return await _getLastInsertRowID();
  }

  String? getFieldType(Type type) {
    switch (type) {
      case String:
        return TEXT;
      case int:
        return INTEGER;
      case double:
        return DOUBLE;
      case bool:
        return BOOLEAN;
      case DateTime:
        return DATETIME;
      case List:
        return LIST;
    }

    return SQL_OBJECT;
    // if field have type of object (SQL_OBJECT or LIST) - we should create separate table for this type of object
    // and leave in current object only link to object in another table
  }

  Future createTable(Map<String, Type> object,
      {bool isChild = false, String? name}) async {
    var tableName = name ?? dbTableName;
    String fields = "";
    //if (isChild) {
    fields += "DB_ID INTEGER PRIMARY KEY,";
    //}
    object.forEach((key, t) {
      var type = getFieldType(t);
      if (type != LIST && type != SQL_OBJECT && type != BOOLEAN) {
        fields += ' $key $type NULL,\n';
      } else {
        //here be a link for object in another table
        fields += ' $key TEXT,\n';
      }
    });
    fields = fields.substring(0, fields.length - 2);

    var query = """CREATE TABLE IF NOT EXISTS $tableName(
$fields
    );""";
    nzdb.execute(query);
  }

  Future<bool> tableIsExists(String name) async {
    var r = await nzdb.rawQuery(
        """SELECT name FROM sqlite_master WHERE type='table' AND name='$name';""");

    return r.isNotEmpty;
  }
}
