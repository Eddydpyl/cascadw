class Book {
  String title;
  String image;
  String summary;
  String first;

  Book({
    this.title,
    this.image,
    this.summary,
    this.first,
  });

  Book.fromRaw(Map map)
      : this.title = map["title"],
        this.image = map["image"],
        this.summary = map["summary"],
        this.first = map["first"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (title != null) json["title"] = title;
    if (image != null) json["image"] = image;
    if (summary != null) json["summary"] = summary;
    if (first != null) json["first"] = first;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Book &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              image == other.image &&
              summary == other.summary &&
              first == other.first;

  @override
  int get hashCode =>
      title.hashCode ^
      image.hashCode ^
      summary.hashCode ^
      first.hashCode;

  @override
  String toString() {
    return 'Book{title: $title, image: $image, summary: $summary, first: $first}';
  }
}