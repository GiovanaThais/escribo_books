import 'package:escribo_books/http/http_client.dart';
import 'package:escribo_books/pages/favorites_page.dart';
import 'package:escribo_books/repositories/book_repository.dart';
import 'package:escribo_books/widgets/custom_drawer_widget.dart';
import 'package:escribo_books/stores/book_store.dart';
import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import 'page1.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pagePosition = 0;
  PageController controller = PageController(initialPage: 0);

  final pagesList = <Widget>[
    const Page1(
      title: '',
    ),
    const FavoritesPage(),
  ];

  final navigationBarList = const [
    BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "Favoritos", icon: Icon(Icons.bookmark)),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            widget.title,
          ),
        ),
        drawer: const CustomDrawerWidget(),
        body: PageView(
          controller: controller,
          onPageChanged: (value) {
            setState(() {
              pagePosition = value;
            });
          },
          scrollDirection: Axis.vertical,
          children: pagesList,
        ),
        bottomNavigationBar: BottomNavigationBar(
            onTap: (value) {
              controller.jumpToPage(value);
            },
            currentIndex: pagePosition,
            items: navigationBarList),
      ),
    );
  }
}
