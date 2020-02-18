class Chapter {
  String book;
  String source;
  String uid;
  String title;
  String content;
  int hearts;
  int random;

  bool bookmarked = false;
  bool hearted = false;

  static const int MAX_RANDOM = 128000;

  Chapter({
    this.book,
    this.source,
    this.uid,
    this.title,
    this.content,
    this.hearts,
    this.random,
  });

  Chapter.fromRaw(Map map)
      : this.book = map["book"],
        this.source = map["source"],
        this.uid = map["uid"],
        this.title = map["title"],
        this.content = map["content"],
        this.hearts = map["hearts"],
        this.random = map["random"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (book != null) json["book"] = book;
    if (source != null) json["source"] = source;
    if (uid != null) json["uid"] = uid;
    if (title != null) json["title"] = title;
    if (content != null) json["content"] = content;
    if (hearts != null) json["hearts"] = hearts;
    if (random != null) json["random"] = random;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Chapter &&
              runtimeType == other.runtimeType &&
              book == other.book &&
              source == other.source &&
              uid == other.uid &&
              title == other.title &&
              content == other.content &&
              hearts == other.hearts &&
              random == other.random;

  @override
  int get hashCode =>
      book.hashCode ^
      source.hashCode ^
      uid.hashCode ^
      title.hashCode ^
      content.hashCode ^
      hearts.hashCode ^
      random.hashCode;

  @override
  String toString() {
    return 'Chapter{book: $book, source: $source, uid: $uid, title: $title,'
        ' content: $content, hearts: $hearts, random: $random}';
  }
}