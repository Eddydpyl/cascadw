class AppUser {
  String email;
  String name;
  String about;
  String avatar;

  AppUser({
    this.email,
    this.name,
    this.about,
    this.avatar,
  });

  AppUser.fromRaw(Map map)
      : this.email = map["email"],
        this.name = map["name"],
        this.about = map["about"],
        this.avatar = map["avatar"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (email != null) json["email"] = email;
    if (name != null) json["name"] = name;
    if (about != null) json["about"] = about;
    if (avatar != null) json["avatar"] = avatar;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppUser &&
              runtimeType == other.runtimeType &&
              email == other.email &&
              name == other.name &&
              about == other.about &&
              avatar == other.avatar;

  @override
  int get hashCode =>
      email.hashCode ^
      name.hashCode ^
      about.hashCode ^
      avatar.hashCode;

  @override
  String toString() {
    return 'AppUser{email: $email, name: $name, about: $about, avatar: $avatar}';
  }
}