import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/book.dart';

/// REPOSITORIES MUST NOT BE STORED IN VARIABLES OR INSTANTIATED DIRECTLY!
/// These are only to be used as an interface for the model's methods, and
/// should only be accessed by making the appropriate call in DatabaseManager.

class BookRepository {
  final Firestore _database;

  BookRepository(this._database);

  Future<String> create(Book book) async {
    DocumentReference reference = _database.collection("books").document();
    reference.setData(book.toJson());
    return reference.documentID;
  }

  Future<Book> read(String key) async {
    DocumentReference reference = _database.collection("books").document(key);
    DocumentSnapshot snapshot = await reference.get();
    return snapshot?.data != null ? Book.fromRaw(snapshot.data) : null;
  }

  Future<Map<String, Book>> readAll() async {
    Query reference = _database.collection("books");
    QuerySnapshot snapshot = await reference.getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents ?? [];
    List<MapEntry<String, Book>> entries = documents.map((document) =>
        MapEntry<String, Book>(document.documentID, Book.fromRaw(document.data))).toList();
    return Map.fromEntries(entries);
  }

  Future<dynamic> update(String key, Book book) {
    DocumentReference reference = _database.collection("books").document(key);
    return reference.updateData(book.toJson());
  }

  Future<dynamic> delete(String key) async {
    DocumentReference reference = _database.collection("books").document(key);
    return reference.delete();
  }

  Stream<MapEntry<String, Book>> valueStream(String key) {
    DocumentReference reference = _database.collection("books").document(key);
    return reference.snapshots().map((snapshot) => snapshot?.data != null
        ? MapEntry(snapshot.documentID, Book.fromRaw(snapshot.data)) : null);
  }

  Stream<Map<String, Book>> collectionStream() {
    Query reference = _database.collection("books");
    return reference.snapshots().map((snapshot) {
      List<DocumentSnapshot> documents = snapshot.documents ?? [];
      List<MapEntry<String, Book>> entries = documents.map((document) =>
          MapEntry<String, Book>(document.documentID, Book.fromRaw(document.data))).toList();
      return Map.fromEntries(entries);
    });
  }
}