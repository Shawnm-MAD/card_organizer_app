class Folder {
  final int id;
  final String name;

  Folder({required this.id, required this.name});

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}

class CardItem {
  final int id;
  final String name;
  final String suit;
  final String imageUrl;
  final int folderId;

  CardItem({
    required this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    required this.folderId,
  });

  factory CardItem.fromMap(Map<String, dynamic> map) {
    return CardItem(
      id: map['id'],
      name: map['name'],
      suit: map['suit'],
      imageUrl: map['image_url'],
      folderId: map['folder_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // SQLite auto-generates this
      'name': name,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    };
  }
}
