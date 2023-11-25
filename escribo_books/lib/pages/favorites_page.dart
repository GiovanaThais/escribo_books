import 'package:flutter/material.dart';

import '../stores/book_store.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage(
      {super.key,
      required this.title,
      required this.store,
      required this.onEbookTap});
  final BookStore store;

  final String title;

  final void Function({required String fiileUrl, required String bookName})
      onEbookTap;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  BookStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    // store.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          store.isLoading,
          store.erro,
          store.favoriteList,
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

          if (store.favoriteList.value.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item na lista de favoritos',
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
              itemCount: store.favoriteList.value.length,
              itemBuilder: (_, index) {
                final isFavorite = store.favoriteList.value
                    .contains(store.favoriteList.value[index]);
                final item = store.favoriteList.value[index];
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
                            onTap: () => widget.onEbookTap(
                                bookName: item.title,
                                fiileUrl: item.download_url),
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
                              store.addAndRemoveFavorite(item);
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
