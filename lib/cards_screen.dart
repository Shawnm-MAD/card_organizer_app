import 'package:flutter/material.dart';
import 'helper.dart';
import 'models.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  CardsScreen({required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Future<List<CardItem>> _cards;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    setState(() {
      _cards = _fetchCards();
    });
  }

  Future<List<CardItem>> _fetchCards() async {
    final cardMaps = await DatabaseHelper.instance.getCards(widget.folder.id);
    return cardMaps.map((map) => CardItem.fromMap(map)).toList();
  }

  void _addCard() async {
    try {
      CardItem newCard = CardItem(
        id: 0, // Will be auto-generated
        name: "New ${widget.folder.name} Card",
        suit: widget.folder.name.toLowerCase(),
        imageUrl: "assets/images/card_placeholder.png",
        folderId: widget.folder.id,
      );

      await DatabaseHelper.instance.addCard(newCard.toMap());
      _loadCards();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _deleteCard(int cardId) async {
    await DatabaseHelper.instance.deleteCard(cardId);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.folder.name} Cards")),
      body: FutureBuilder<List<CardItem>>(
        future: _cards,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              CardItem card = snapshot.data![index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Image.asset(card.imageUrl, width: 50, height: 50),
                  title: Text(card.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(card.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}
