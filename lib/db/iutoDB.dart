import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/models/preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IutoDB extends ChangeNotifier {
  static Database? _db;

  late List<Preferences> preferences;

  Sqflite() {
    preferences = [];
  }

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'iuto.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE Preferences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idCuisine INTEGER NOT NULL,
            idU TEXT NOT NULL,
            FOREIGN KEY (idCuisine) REFERENCES type_cuisine (id)
          )
        ''');
    });
  }

  Future<void> insertPreference(String idU, int idCuisine) async {
    try {
      final db = await this.db;
      await db!.insert(
        'Preferences',
        {'idCuisine': idCuisine, 'idU': idU},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      refreshPreferences();
    } catch (e) {
      debugPrint('Erreur lors de l\'insertion de la préférence : $e');
    }
  }


  Future<List<Preferences>> getPreferences(String idU) async {
    try {
      final db = await this.db;
      final List<Map<String, dynamic>> maps = await db!.query(
        'Preferences',
        where: 'idU = ?',
        whereArgs: [idU],
      );
      preferences = List.generate(maps.length, (i) {
        return Preferences.fromMap(maps[i]);
      });
      return preferences;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des préférences : $e');
      return [];
    }
  }

  Future<void> deleteAllPreferences(String idU) async {
    try {
      final db = await this.db;
      await db!.delete(
        'Preferences',
        where: 'idU = ?',
        whereArgs: [idU],
      );
      refreshPreferences();
    } catch (e) {
      debugPrint('Erreur lors de la suppression des préférences : $e');
    }
  }

  Future<void> closeDb() async {
    final db = await this.db;
    await db!.close();
  }

  Future<void> clearDatabase() async {
    final db = await this.db;
    await db!.execute('DELETE FROM Preferences');
    refreshPreferences();
  }

  Future<void> deleteDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'iuto.db');
    await deleteDatabase(path);
    _db = null;
  }

  Future<void> refreshPreferences() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        preferences = await getPreferences(user.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des préférences : $e');
    }
  }
}
