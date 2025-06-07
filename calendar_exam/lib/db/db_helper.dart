import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/event_model.dart';
import '../models/user_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calendar_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> resetDatabase() async {
    final path = await getDatabasesPath();
    await deleteDatabase('$path/calendar_app.db');
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        color TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(createdBy) REFERENCES users(uid)
      );
    ''');
  }

  // USER METHODS
  static Future<int> insertUser(UserModel user) async {
    final db = await database;

    final hashedUser = UserModel(
      id: user.id,
      uid: user.uid,
      email: user.email.toLowerCase().trim(),
      name: user.name.trim(),
      password: UserModel.hashPassword(user.password.trim()),
      createdAt: user.createdAt,
    );

    return await db.insert(
      'users',
      hashedUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  static Future<UserModel?> getUserByUid(String uid) async {
    final db = await database;
    final result = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  static Future<UserModel?> login(String email, String password) async {
    final db = await database;

    final result = await db.query('users', where: 'email = ?', whereArgs: [email.toLowerCase()]);
    print('pass in db: ${result.first['password']}');

    if (result.isNotEmpty) {
      final user = UserModel.fromMap(result.first);
      final hashedInput = UserModel.hashPassword(password);

      print('––––––––––––––––––––––––');
      print('inputt pass: $password');
      print('hash input pass: $hashedInput');
      print('hash on db: ${user.password}');
      print('are they equal? ${user.password == hashedInput}');
      print('––––––––––––––––––––––––');

      if (user.password == hashedInput) {
        return user;
      }
    }

    return null;
  }

  // EVENT METHODS
  static Future<int> insertEvent(EventModel event) async {
    final db = await database;
    return await db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<EventModel>> getEventsByDate(String date, String uid) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT * FROM events
    WHERE DATE(startTime) = DATE(?) AND createdBy = ?
    ORDER BY startTime ASC
  ''', [date, uid]);

    return result.map((e) => EventModel.fromMap(e)).toList();
  }

  static Future<List<EventModel>> getAllEventsByDate(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT * FROM events
    WHERE DATE(startTime) = DATE(?)
    ORDER BY startTime ASC
  ''', [date]);

    return result.map((e) => EventModel.fromMap(e)).toList();
  }

  static Future<List<EventModel>> getUserEvents(String uid) async {
    final db = await database;
    final result = await db.query('events', where: 'createdBy = ?', whereArgs: [uid]);
    return result.map((e) => EventModel.fromMap(e)).toList();
  }

  static Future<int> updateEvent(EventModel event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  static Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

}