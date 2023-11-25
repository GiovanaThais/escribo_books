import 'dart:convert';
import 'dart:developer';

import 'package:escribo_books/http/exceptions.dart';
import 'package:escribo_books/http/http_client.dart';
import 'package:escribo_books/model/book_model.dart';

abstract class IBookRepository {
  Future<List<BookModel>> getBooks();
}

class BookRepository implements IBookRepository {
  final IHttpClient client;

  BookRepository({required this.client});

  @override
  Future<List<BookModel>> getBooks() async {
    final response = await client
        .get(url: 'https://escribo.com/books.json')
        .onError((error, stackTrace) {
      log(error.toString());
    });

    if (response.statusCode == 200) {
      final List<BookModel> books = [];

      final body = jsonDecode(response.body);

      body.map((item) {
        final BookModel book = BookModel.fromMap(item);
        books.add(book);
      }).toList();

      return books;
    } else if (response.statusCode == 400) {
      throw NotFoundException('Url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os livros');
    }
  }
}
