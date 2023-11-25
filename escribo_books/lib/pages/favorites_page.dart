import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Favoritos"),
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            margin: EdgeInsets.all(16),
            width: double.infinity,
            color: Color.fromARGB(255, 211, 245, 255),
            child: const Card(
              elevation: 7,
              shadowColor: Color.fromARGB(255, 93, 223, 213),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Favorito"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
