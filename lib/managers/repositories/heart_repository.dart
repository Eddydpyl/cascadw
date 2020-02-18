import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/heart.dart';

/// REPOSITORIES MUST NOT BE STORED IN VARIABLES OR INSTANTIATED DIRECTLY!
/// These are only to be used as an interface for the model's methods, and
/// should only be accessed by making the appropriate call in DatabaseManager.

class HeartRepository {
  final Firestore _database;
  final String _uid;

  HeartRepository(this._database, this._uid);

  Future<String> create(Heart heart) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("hearts").document();
    reference.setData(heart.toJson());
    return reference.documentID;
  }

  Future<Heart> read(String key) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("hearts").document(key);
    DocumentSnapshot snapshot = await reference.get();
    return snapshot?.data != null ? Heart.fromRaw(snapshot.data) : null;
  }

  Future<Map<String, Heart>> readAll({String book, String chapter}) async {
    Query reference = _database.collection("users").document(_uid).collection("hearts");
    if (book != null) reference = reference.where("book", isEqualTo: book);
    if (chapter != null) reference = reference.where("chapter", isEqualTo: chapter);
    QuerySnapshot snapshot = await reference.getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents ?? [];
    List<MapEntry<String, Heart>> entries = documents.map((document) =>
        MapEntry<String, Heart>(document.documentID, Heart.fromRaw(document.data))).toList();
    return Map.fromEntries(entries);
  }

  Future<dynamic> update(String key, Heart heart) {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("hearts").document(key);
    return reference.updateData(heart.toJson());
  }

  Future<dynamic> delete(String key) async {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("hearts").document(key);
    return reference.delete();
  }

  Stream<MapEntry<String, Heart>> valueStream(String key) {
    DocumentReference reference = _database.collection("users")
        .document(_uid).collection("hearts").document(key);
    return reference.snapshots().map((snapshot) => snapshot?.data != null
        ? MapEntry(snapshot.documentID, Heart.fromRaw(snapshot.data)) : null);
  }

  Stream<Map<String, Heart>> collectionStream({String book, String chapter}) {
    Query reference = _database.collection("users").document(_uid).collection("hearts");
    if (book != null) reference = reference.where("book", isEqualTo: book);
    if (chapter != null) reference = reference.where("chapter", isEqualTo: chapter);
    return reference.snapshots().map((snapshot) {
      List<DocumentSnapshot> documents = snapshot.documents ?? [];
      List<MapEntry<String, Heart>> entries = documents.map((document) =>
          MapEntry<String, Heart>(document.documentID, Heart.fromRaw(document.data))).toList();
      return Map.fromEntries(entries);
    });
  }
}