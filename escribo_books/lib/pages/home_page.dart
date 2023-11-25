import 'package:escribo_books/http/http_client.dart';
import 'package:escribo_books/pages/reader_page.dart';
import 'package:escribo_books/repositories/book_repository.dart';
import 'package:escribo_books/repositories/custom_drawer_widget.dart';
import 'package:escribo_books/stores/book_store.dart';
import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

//import 'page1.dart';
import 'page2.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BookStore store = BookStore(
      repository: BookRepository(
    client: HttpClient(),
  ));
  int pagePosition = 0;
  PageController controller = PageController(initialPage: 0);

  final pagesList = <Widget>[
    //const Page1(),
    const Page2(),
  ];

  @override
  void initState() {
    super.initState();
    store.getBooks();
  }

  final navigationBarList = const [
    BottomNavigationBarItem(label: "Pag1", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "Pag2", icon: Icon(Icons.bookmark)),
  ];
  Future<void> _downloadAndOpenBook(String downloadUrl) async {
    try {
      String filePath = await _downloadFile(downloadUrl);
      _openEpubReader(filePath);
    } catch (e) {
      // Lógica para lidar com erros durante o download
      print("Erro durante o download: $e");
    }
  }

  Future<String> _downloadFile(String url) async {
    // Lógica para download do arquivo

    //url ficticia
    return "/path/to/downloaded/book.epub";
  }

  void _openEpubReader(String filePath) {
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "book_identifier",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: false,
    );

    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
    });

    VocsyEpub.open(
      filePath,
      lastLocation: EpubLocator.fromJson({
        "bookId": "book_identifier",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"},
      }),
    );
  }

  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const CustomDrawerWidget(),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          store.isLoading,
          store.erro,
          store.state,
        ]),
        builder: (context, child) {
          if (store.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.erro.value.isNotEmpty) {
            return Center(
              child: Text(
                store.erro.value,
                style: const TextStyle(
                  color: Color.fromARGB(136, 0, 0, 0),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (store.state.value.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item na lista',
                style: TextStyle(
                  color: Color.fromARGB(136, 4, 0, 0),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                height: 32,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: store.state.value.length,
              itemBuilder: (_, index) {
                final item = store.state.value[index];
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey, // Largura da borda
                            ),
                          ),
                          child: InkWell(
                            hoverColor: Colors.grey,
                            onTap: () async {
                              await _downloadAndOpenBook(item.download_url);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item.cover_url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                                focusColor: Colors.white,
                                padding: EdgeInsets.all(-10),
                                icon: const Icon(
                                  Icons.bookmark,
                                  size: 40,
                                ),
                                onPressed: () {
                                  isBookmarked = !isBookmarked;
                                })
                            //
                            ),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReaderPage()));
                        },
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Color.fromARGB(136, 34, 89, 140),
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.author,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 76, 89, 175),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.download_url,
                            style: const TextStyle(
                              color: Color.fromARGB(137, 108, 44, 44),
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
