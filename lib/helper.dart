import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Folder {
  int id;
  String name;
  String imageUrl;
  int cardCount;

  Folder({required this.id, required this.name, required this.imageUrl, required this.cardCount});
}

class CardItem {
  int id;
  String name;
  String suit;
  String imageUrl;
  int folderId;

  CardItem({required this.id, required this.name, required this.suit, required this.imageUrl, required this.folderId});
}

Future<Database> initDatabase() async {
  var dbPath = await getDatabasesPath();
  String path = join(dbPath, 'cards.db');
  
  return openDatabase(path, onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE Folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imageUrl TEXT,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        suit TEXT,
        imageUrl TEXT,
        folderId INTEGER,
        FOREIGN KEY (folderId) REFERENCES Folders(id)
      )
    ''');
    // Prepopulate the Folders table
    await db.insert('Folders', {'name': 'Hearts', 'imageUrl': 'hearts.png'});
    await db.insert('Folders', {'name': 'Spades', 'imageUrl': 'spades.png'});
    await db.insert('Folders', {'name': 'Diamonds', 'imageUrl': 'diamonds.png'});
    await db.insert('Folders', {'name': 'Clubs', 'imageUrl': 'clubs.png'});
  }, version: 1);
}
