import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'SentTexts.dart';

class SentDb {
  SentDb._();
  static final SentDb db = SentDb._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, "SentTexts.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE SentTexts ("
          "id INTEGER PRIMARY KEY,"
          "sentNo INTEGER"
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

  newSentTexts(SentTexts newSentTexts) async {
    final db = await database;
    //var d = await db.execute("DROP TABLE Text");
    //var f = await db.execute("ALTER TABLE Text "
    //                        "ADD number TEXT");
    var res = await db.insert("SentTexts", newSentTexts.toMap());
    return res;
  }


  Future<List<SentTexts>> getAllSentTexts() async {
    final db = await database;
    var res = await db.query("SentTexts");
    List<SentTexts> list = res.isNotEmpty ? res.map((c) => SentTexts.fromMap(c)).toList() : [];
    return list;
  }

  updateSentTexts(SentTexts newSentTexts) async {
    final db = await database;
    var res = await db.update("SentTexts", newSentTexts.toMap(),
        where: "id = ?", whereArgs: [newSentTexts.id]);
    return res;
  }


}

/*
Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all((Radius.circular(5))),
                            border: Border.all(color: HexColor("D2D2D2")),
                          ),
                          child: Padding(
                            padding: new EdgeInsets.fromLTRB(7, 8, 0, 8),
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.top,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              decoration: new InputDecoration(
                                  labelText: "Enter your message",
                                  prefixIcon: Icon(Icons.message, size: 20)
                              ),
                              validator: (val) =>
                              val.length == 0 ? "Please enter a message" : null,
                              onSaved: (val) => this.text = val,
                            ),
                          ),
                        ),

                        Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all((Radius.circular(15))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(1, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: new EdgeInsets.fromLTRB(20, 15, 0, 0),
                            child: Text("Time", style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                      FlatButton(onPressed: () {
                        _pickTime();
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all((Radius.circular(5))),
                            border: Border.all(color: HexColor("D2D2D2")),
                          ),
                          child: Padding(
                            padding: new EdgeInsets.fromLTRB(7, 8, 0, 8),
                            child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 20, color: HexColor("A1A1A1"),),
                                  Padding(
                                    padding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text('$setTime', style: TextStyle(fontSize: 16.0, color: HexColor("BABABA")),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
 */