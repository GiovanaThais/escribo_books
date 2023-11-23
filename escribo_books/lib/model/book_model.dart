class BookModel {
  final String title;
  final String author;
  final String cover_url; //image
  final String download_url;

  BookModel(
      {required this.title,
      required this.author,
      required this.cover_url,
      required this.download_url});
  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
        title: map['title'],
        author: map['author'],
        cover_url: map['cover_url'],
        download_url: map['download_url']);
  }
}
