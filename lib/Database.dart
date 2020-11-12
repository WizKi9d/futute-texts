import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Text.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, "Texts.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Text ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          "text TEXT,"
          "date INTEGER,"
          "time TEXT,"
          "number TEXT"
          ")");
    });
  }

  /*
  await db.execute("CREATE TABLE Text ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          "text TEXT"
          "date DATE"
          ")");
   */

  newClient(Client newClient) async {
    final db = await database;
    //var d = await db.execute("DROP TABLE Text");
    //var f = await db.execute("ALTER TABLE Text "
     //                        "ADD number TEXT");
    var res = await db.insert("Text", newClient.toMap());
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res = await db.query("Text", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : Null;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    var res = await db.query("Text");
    List<Client> list = res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }


  getSpecific() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Text WHERE text = 'yes'");
    List<Client> list =
        res.isNotEmpty ? res.toList().map((c) => Client.fromMap(c)) : null;
    return list;
  }

  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Text", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  changeText(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        text: client.text += "...");
    var res = await db.update("Text", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  deleteClient(int id) async {
    final db = await database;
    db.delete("Text", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE FROM Text");
  }

}