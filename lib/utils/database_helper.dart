import 'dart:io';
import 'dart:async';
import 'package:notekeeper/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //Singleton object/instance
  static DatabaseHelper _databaseHelper;

  static Database _database;
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //Named Constructor to create instance of DatabaseHelper
  factory DatabaseHelper() {
    //initalizing object by calling a named constructor

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); //This is executed only once, singleton object
    }

    return _databaseHelper;
  }
//Getter for our database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and iOS to store database

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Open/create the database at a given path
    var notesDatabse =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabse;
  }

//function Create database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    // var result =
    //     await db.rawQuery('SELECT * FROM $noteTable order by $colPriority');

    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //Insert Operation: nsert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update Operation: Update a Note object and save it to databse
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //Delete number of Note objects in database
  deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FORM $noteTable WHERE $colId = $id');
    return result;
  }

  //Get number of Note onjects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) form $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Get the 'Map List' [List<Map>] and convert it to 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); //Get 'Map List' from database
    int count =
        noteMapList.length; //Count the number of map entries in db table

    List<Note> noteList = [];
    //For loop to create a 'note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.formMapObject(noteMapList[i]));
    }
    return noteList;
  }
}

//1.
//Singleton DatabaseHelper (this instance only initilized only
//once through out application and use it within our application
//till the application shots down)
//2
//factory constructor (this factory constructor allows you
// to return some values i.e we have used _databaseHelper)
//3.
//this null check statement ensure that we will create the
//the inscatnce of the database helper only if it is null,
//so, this way this statement will only be executed only once,
//within our application
