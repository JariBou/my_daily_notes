import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_daily_notes/models/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    Directory dir = await getApplicationDocumentsDirectory();
    final dbPath = dir.path;
    final path = join(dbPath, filepath);

    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _updateDB);
  }

  FutureOr<void> _updateDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('''DROP TABLE ${NoteTables.draftNotes}''');
    await db.execute('''DROP TABLE ${NoteTables.receivedNotes}''');
    await db.execute('''DROP TABLE ${NoteTables.sentNotes}''');

    _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE ${NoteTables.draftNotes} ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType,
  ${NoteFields.author} $textType
  )
''');
    await db.execute('''
CREATE TABLE ${NoteTables.receivedNotes} ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType,
    ${NoteFields.author} $textType
)
''');
    await db.execute('''
CREATE TABLE ${NoteTables.sentNotes} ( 
  ${NoteFields.id} $idType, 
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.time} $textType,
    ${NoteFields.author} $textType
)
''');
  }

  Future<Note> create(Note note, String table) async {
    final db = await instance.database;
    final id = await db.insert(table.toString(), note.toJson());
    return note.copy(id: id);
  }

  Future<Note> readNote(int id, String table) async {
    final db = await instance.database;

    final maps = await db.query(
      table.toString(),
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('Id $id not found!');
    }
  }

  Future<List<Note>> readAllNotes(String table) async {
    final db = await instance.database;

    const orderBy = '${NoteFields.time} ASC';
    final result = await db.query(table.toString(), orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note, String table) async {
    final db = await instance.database;

    return db.update(
      table.toString(),
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id, String table) async {
    final db = await instance.database;

    return db.delete(
      table.toString(),
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
