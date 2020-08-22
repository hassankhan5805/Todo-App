import 'dart:async';
import 'dart:io';

import 'package:no_todo/model/notodo_item.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  final String tableName = 'nodoTbl';
  final String columnId = 'id';
  final String columnItemName = 'itemName';
  final String columnDateCreated = 'dateCreated';
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notodo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDateCreated TEXT)");
    print('Table is Created');
  }

  Future<int> saveItem(NoToDoItems item) async {
    var dbClient = await db;
    int res = await dbClient.insert('$tableName', item.toMap());
    print(res.toString());
    return res;
  }

  Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $tableName ORDER BY $columnDateCreated ASC");
    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient
        .rawQuery("SELECT * FROM $tableName WHERE id = $columnId"));
  }

  Future<NoToDoItems> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery('SELECT * FROM $tableName WHERE id = $columnId');
    if (result.length == 0) return null;
    return new NoToDoItems.fromMap(result.first);
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateItem(NoToDoItems item) async {
    var dbClient = await db;
    return await dbClient.update('$tableName', item.toMap(),
        where: '$columnId = ?', whereArgs: [item.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
