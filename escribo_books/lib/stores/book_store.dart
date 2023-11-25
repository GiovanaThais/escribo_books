import 'package:escribo_books/http/exceptions.dart';
import 'package:escribo_books/model/book_model.dart';
import 'package:escribo_books/repositories/book_repository.dart';
import 'package:flutter/material.dart';

class BookStore {
  final IBookRepository repository;
  //variavel reativa para o loading
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  //variavel reativa para o state
  final ValueNotifier<List<BookModel>> state =
      ValueNotifier<List<BookModel>>([]);

  //variavel reativa para o favoritos
  final ValueNotifier<List<BookModel>> favoriteList =
      ValueNotifier<List<BookModel>>([]);

  //variavel reativa para o erro
  final ValueNotifier<String> erro = ValueNotifier<String>('');

  BookStore({required this.repository});

  Future getBooks() async {
    isLoading.value = true;

    try {
      final result = await repository.getBooks();
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } catch (e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  }

  void addAndRemoveFavorite(BookModel book) {
    if (favoriteList.value.contains(book)) {
      favoriteList.value.remove(book);
    } else {
      favoriteList.value.add(book);
    }
    favoriteList.notifyListeners();
  }
}
