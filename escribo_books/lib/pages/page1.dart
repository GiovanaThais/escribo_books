import 'package:escribo_books/model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:escribo_books/http/http_client.dart';
import 'package:escribo_books/pages/favorites_page.dart';
import 'package:escribo_books/repositories/book_repository.dart';
import 'package:escribo_books/repositories/custom_drawer_widget.dart';
import 'package:escribo_books/stores/book_store.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key, required this.title});

  final String title;

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final BookStore store = BookStore(
      repository: BookRepository(
    client: HttpClient(),
  ));
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

    VocsyEpub.open(
      filePath,
      lastLocation: EpubLocator.fromJson({
        "bookId": "book_identifier",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"},
      }),
    );
    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $BookRepository');
    });
  }

  bool isBookmarked = false;

  final List<BookModel> _favoritesList = [];

  @override
  void initState() {
    super.initState();
    store.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final isFavorite =
                    _favoritesList.contains(store.state.value[index]);
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
                          right: -7,
                          top: -13,
                          child: IconButton(
                            focusColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                //  isBookmarked = true;
                                if (isFavorite) {
                                  _favoritesList
                                      .remove(store.state.value[index]);
                                } else {
                                  _favoritesList.add(store.state.value[index]);
                                }
                              });
                            },
                            icon: isFavorite
                                ? const Icon(
                                    Icons.bookmark,
                                    color: Colors.red,
                                    size: 40,
                                  )
                                : const Icon(
                                    Icons.bookmark_outline,
                                    size: 40,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: InkWell(
                        onTap: () {},
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Color.fromARGB(134, 19, 132, 177),
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
                              color: Color.fromARGB(255, 76, 130, 175),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.download_url,
                            style: const TextStyle(
                              color: Color.fromARGB(133, 1, 107, 255),
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
