import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cards.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = join(dbPath, path);
    return await openDatabase(dbLocation, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id)
      );
    ''');

    // Prepopulate folder data (Hearts, Spades, Diamonds, Clubs)
    await db.insert('folders', {'name': 'Hearts'});
    await db.insert('folders', {'name': 'Spades'});
    await db.insert('folders', {'name': 'Diamonds'});
    await db.insert('folders', {'name': 'Clubs'});

    // Prepopulate cards (for simplicity, only a few cards here)
    for (var suit in ['hearts', 'spades', 'diamonds', 'clubs']) {
      for (var i = 1; i <= 13; i++) {
        String cardName = '${i}_of_$suit';
        String imageUrl =
            'assets/images/${cardName.toLowerCase().replaceAll(' ', '_')}.png';
        await db.insert('cards', {
          'name': cardName,
          'suit': suit,
          'image_url': imageUrl,
          'folder_id':
              (suit == 'hearts')
                  ? 1
                  : (suit == 'spades')
                  ? 2
                  : (suit == 'diamonds')
                  ? 3
                  : 4,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await instance.database;
    return await db.query('folders');
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    final db = await instance.database;
    return await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> addCard(Map<String, dynamic> card) async {
    final db = await instance.database;
    final folderId = card['folder_id'];
    final cardCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cards WHERE folder_id = ?', [
        folderId,
      ]),
    );

    if (cardCount != null && cardCount >= 6) {
      throw Exception('This folder can only hold 6 cards.');
    }

    return await db.insert('cards', card);
  }

  Future<int> deleteCard(int cardId) async {
    final db = await instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }

  Future<int> deleteFolder(int folderId) async {
    final db = await instance.database;
    await db.delete('cards', where: 'folder_id = ?', whereArgs: [folderId]);
    return await db.delete('folders', where: 'id = ?', whereArgs: [folderId]);
  }
}
