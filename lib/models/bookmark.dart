class Bookmark {
  String book;
  String chapter;

  Bookmark({
    this.book,
    this.chapter,
  });

  Bookmark.fromRaw(Map map)
      : this.book = map["book"],
        this.chapter = map["chapter"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (book != null) json["book"] = book;
    if (chapter != null) json["chapter"] = chapter;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bookmark &&
              runtimeType == other.runtimeType &&
              book == other.book &&
              chapter == other.chapter;

  @override
  int get hashCode =>
      book.hashCode ^
      chapter.hashCode;

  @override
  String toString() {
    return 'Bookmark{book: $book, chapter: $chapter}';
  }
}