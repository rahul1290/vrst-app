import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static final _databasename = "vrst.db";
  static final _databaseversion = 1;

  static final table = "employee";
  static final columnID = 'id';
  static final columnName = 'name';
  static final columnState = 'state';
  static final columnContact = 'contact';
  static final columnkey = 'key';
  static final columnimage = 'image';
  static final columnfirebasekey = 'firebase';

  static final table1 = "billEntries";
  static final columnId = 'id';
  static final columnCrop = 'crop';
  static final columnVariety = 'variety';
  static final columnQty = 'qty';

  static Database _database;
  Databasehelper._privateConstructor();
  static final Databasehelper instance = Databasehelper._privateConstructor();

  Future<Database> get databse async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async{
    Directory documentdirectory = await getApplicationDocumentsDirectory();
    String path = join(documentdirectory.path,_databasename);
    return await openDatabase(path,version: _databaseversion,onCreate: _onCreate);
  }

  Future _onCreate(Database db,int version) async{
    await db.execute("CREATE TABLE $table($columnID INTEGER PRIMARY KEY,$columnName TEXT NOT NULL,$columnState TEXT NOT NULL,$columnContact VARCHAR(11) NOT NULL,$columnkey TEXT NOT NULL,$columnimage TEXT NOT NULL,$columnfirebasekey TEXT)");
    await db.execute("CREATE TABLE $table1($columnId INTEGER PRIMARY KEY,$columnCrop INTEGER NOT NULL,$columnVariety INTEGER NOT NULL,$columnQty INTEGER NOT NULL)");
  }

////////////////////////////////Bill Entries
  Future<int>insertBill(Map<String,dynamic> row) async{
    Database db = await instance.databse;
    return await db.insert(table1, row);
  }

  Future <List> maxId() async{
    Database db = await instance.databse;
    return await db.rawQuery("select count(*) as count from $table1");
  }

  Future<List>getallentries() async {
    Database db = await instance.databse;
    return await db.query(table1, columns: [columnCrop,columnVariety,columnQty]);
  }

  Future<int>deleteEntriesData() async{
    Database db = await instance.databse;
    var res = await db.delete(table1);
    return res;
  }

  Future deleteEntriesId(int id) async {
    Database db = await instance.databse;
    var res = await db.rawQuery("delete from $table1 where $columnId = $id");
    return res;
  }

  /////////////////////////////////////////
  Future<int>insert(Map<String,dynamic> row) async{
    Database db = await instance.databse;
    return await db.insert(table, row);
  }

  Future<List>getall() async {
    Database db = await instance.databse;
    return await db.query(table, columns: [columnID,columnName,columnState,columnContact,columnkey,columnimage,columnfirebasekey]);
  }

  Future<List>get(int id) async {
    Database db = await instance.databse;
    return await db.rawQuery("select * from $table where $columnID = $id");
  }

//  Future<int>deletedata(int id) async{
//    Database db = await instance.databse;
//    var res = await db.delete(table,where: "id = ?",whereArgs: [id]);
//    return res;
//  }

  Future<int>deletedata() async{
    Database db = await instance.databse;
    var res = await db.delete(table);
    return res;
  }
}