class BooksInformation {
  String bookId;
  String author;
  String title;
  String description;
  int pageNumber;
  String imgStorage;
  String category;
  double rating;
  int deletedAt;
  int pageDeadline;


  BooksInformation({ this.bookId, this.author, this.description, this.title, this.pageNumber, this.imgStorage, this.rating , this.category, this.deletedAt, this.pageDeadline }) ;

  String getBookId() { return bookId; }

  String getAuthor() { return author; }

  String getTitle() { return title; }

  String getDescription() { return description; }

  String getPageNumber() { return pageNumber.toString(); }

  String getImgStorage() { return imgStorage; }

  double getRating() { return rating; }

  String getCategory() { return category; }

  String getDeadline() { return pageDeadline.toString();}

  factory BooksInformation.fromJson(Map<String, dynamic> json) {
    return BooksInformation(
      bookId: json['id'] as String,
      author: json['author'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pageNumber: json['pageNumber'] as int,
      imgStorage: json['imgStorage'] as String,
      rating: json['rating'] as double,
      category: json['category'] as String,
      deletedAt: json['deletedAt'] as int,
      pageDeadline: json['deadline'] as int,
    );
  }
}