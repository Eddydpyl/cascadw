import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/bookmark.dart';

/// REPOSITORIES MUST NOT BE STORED IN VARIABLES OR INSTANTIATED DIRECTLY!
/// These are only to be used as an interface for the model's methods, and
/// should only be accessed by making the appropriate call in DatabaseManager.

class BookmarkRepository {
  final Firestore _database;
  final String _uid;

  BookmarkRepository(this._database, this._uid);

  Future<String> create(Bookmark bookmark) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("bookmarks").document();
    reference.setData(bookmark.toJson());
    return reference.documentID;
  }

  Future<Bookmark> read(String key) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("bookmarks").document(key);
    DocumentSnapshot snapshot = await reference.get();
    return snapshot?.data != null ? Bookmark.fromRaw(snapshot.data) : null;
  }

  Future<Map<String, Bookmark>> readAll({String book, String chapter}) async {
    Query reference = _database.collection("users").document(_uid).collection("bookmarks");
    if (book != null) reference = reference.where("book", isEqualTo: book);
    if (chapter != null) reference = reference.where("chapter", isEqualTo: chapter);
    QuerySnapshot snapshot = await reference.getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents ?? [];
    List<MapEntry<String, Bookmark>> entries = documents.map((document) =>
        MapEntry<String, Bookmark>(document.documentID, Bookmark.fromRaw(document.data))).toList();
    return Map.fromEntries(entries);
  }

  Future<dynamic> update(String key, Bookmark bookmark) {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("bookmarks").document(key);
    return reference.updateData(bookmark.toJson());
  }

  Future<dynamic> delete(String key) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("bookmarks").document(key);
    return reference.delete();
  }

  Stream<MapEntry<String, Bookmark>> valueStream(String key) {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("bookmarks").document(key);
    return reference.snapshots().map((snapshot) => snapshot?.data != null
        ? MapEntry(snapshot.documentID, Bookmark.fromRaw(snapshot.data)) : null);
  }

  Stream<Map<String, Bookmark>> collectionStream({String book, String chapter}) {
    Query reference = _database.collection("users").document(_uid).collection("bookmarks");
    if (book != null) reference = reference.where("book", isEqualTo: book);
    if (chapter != null) reference = reference.where("chapter", isEqualTo: chapter);
    return reference.snapshots().map((snapshot) {
      List<DocumentSnapshot> documents = snapshot.documents ?? [];
      List<MapEntry<String, Bookmark>> entries = documents.map((document) =>
          MapEntry<String, Bookmark>(document.documentID, Bookmark.fromRaw(document.data))).toList();
      return Map.fromEntries(entries);
    });
  }
}