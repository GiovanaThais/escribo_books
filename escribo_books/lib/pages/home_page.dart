import 'package:escribo_books/http/http_client.dart';
import 'package:escribo_books/pages/favorites_page.dart';
import 'package:escribo_books/repositories/book_repository.dart';
import 'package:escribo_books/widgets/custom_drawer_widget.dart';
import 'package:escribo_books/stores/book_store.dart';
import 'package:flutter/material.dart';

import 'page1.dart';
import 'reader_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pagePosition = 0;
  PageController controller = PageController(initialPage: 0);
  final IHttpClient http = HttpClient();
  late final BookStore store = BookStore(
      repository: BookRepository(
    client: HttpClient(),
  ));

  List<Widget> pagesList = [];

  final navigationBarList = const [
    BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "Favoritos", icon: Icon(Icons.bookmark)),
  ];

  @override
  void initState() {
    super.initState();
    initPages();
  }

  void initPages() {
    setState(() {
      pagesList = <Widget>[
        Page1(
          title: '',
          store: store,
          onEbookTap: openEbook,
        ),
        FavoritesPage(
          title: '',
          store: store,
          onEbookTap: openEbook,
        ),
      ];
    });
  }

  Future<void> openEbook(
      {required String fiileUrl, required String bookName}) async {
    // await _downloadAndOpenBook(item.download_url);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReaderPage(
                  bookName: bookName,
                  fiileUrl: fiileUrl,
                  http: http,
                )));
  }

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
