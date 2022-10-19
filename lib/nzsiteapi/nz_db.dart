import 'package:sqflite/sqflite.dart';

late Database nzdb;

class NzDB {
  Future load() async {
    nzdb = await openDatabase('my_db.db');
  }
}
