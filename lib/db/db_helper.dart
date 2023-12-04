import 'package:flutter_diaries/models/diaries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE diary (
  ${NoteTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${NoteTable.image} TEXT NOT NULL,
  ${NoteTable.title} TEXT NOT NULL,
  ${NoteTable.story} TEXT NOT NULL
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }

  Future<List<Map<String, dynamic>>> getAllDiariesRaw() async {
    final db = await instance.database;
    return await db.rawQuery('SELECT * FROM diary');
  }

  insertData() async {
    final db = await instance.database;
    return await db.rawQuery('''INSERT INTO diary ( image, title, story)
VALUES ( '/Users/pond/Library/Developer/CoreSimulator/Devices/67809B79-A15B-4F35-B7D6-4E0370BB713E/data/Containers/Data/Application/11E0103D-6F4C-4B82-982A-BCB36FCEEF5C/tmp/image_picker_3DBD3EF0-8DD7-4CB2-872A-207260535534-78935-000000F3CBAF57E3.jpg', 'Example Title3', 'This is a sample story');
''');
  }

  insertDataViaForm(String image, String title, String story) async {
    final db = await instance.database;
    return await db.rawQuery('''INSERT INTO diary ( image, title, story)
VALUES ( '$image', '$title', '$story');
''');
  }

  Future deleteAllDiaries() async {
    final db = await instance.database;
    await db.delete('diary');
  }

//   selectImagePath(int id) async {
//     final db = await instance.database;
//     String path = (await db.rawQuery('''
//         SELECT image FROM diary WHERE _id = $id;
// );
// ''')) as String;
//     print(path);
//   }

  Future<String?> selectImagePath(int id) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
SELECT image
FROM diary
ORDER BY image DESC
LIMIT 1 OFFSET $id;
  ''');
//WHERE _id = $id
    if (result.isNotEmpty) {
      // Extract the 'image' value from the result
      String imagePath = result.first['image'] as String;
      // print(imagePath);
      return imagePath;
    } else {
      return null; // Return null if no matching entry is found
    }
  }

  deleteById(int? id) async {
    final db = await instance.database;
    await db.delete(
      'diary',
      where: '${NoteTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int?> getIdByTitle(String title) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'diary',
      columns: [NoteTable.id],
      where: '${NoteTable.title} = ?',
      whereArgs: [title],
    );

    if (result.isNotEmpty) {
      print(result.first[NoteTable.id] as int);
      return result.first[NoteTable.id] as int;
    } else {
      return null;
    }
  }
}
