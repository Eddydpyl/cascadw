import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chapter.dart';

/// REPOSITORIES MUST NOT BE STORED IN VARIABLES OR INSTANTIATED DIRECTLY!
/// These are only to be used as an interface for the model's methods, and
/// should only be accessed by making the appropriate call in DatabaseManager.

class ChapterRepository {
  final Firestore _database;

  ChapterRepository(this._database);

  Future<String> create(Chapter chapter) async {
    DocumentReference reference = _database.collection("chapters").document();
    reference.setData(chapter.toJson());
    return reference.documentID;
  }

  Future<Chapter> read(String key) async {
    DocumentReference reference = _database.collection("chapters").document(key);
    DocumentSnapshot snapshot = await reference.get();
    return snapshot?.data != null ? Chapter.fromRaw(snapshot.data) : null;
  }

  Future<Map<String, Chapter>> readAll({String source, int limit, bool random}) async {
    Query reference = _database.collection("chapters");
    if (source != null) reference = reference.where("source", isEqualTo: source);
    if (limit != null) reference = reference.orderBy("hearts", descending: true).limit(limit);
    List<DocumentSnapshot> documents;

    if (random ?? false) {
      if ((limit ?? 1) > 1 || (limit ?? 1) < 1)
        throw Exception("Only one random chapter may be retrived at a time.");
      int number = Random().nextInt(Chapter.MAX_RANDOM);
      Query randomReference = reference.where("random", isLessThanOrEqualTo: number)
          .orderBy("random", descending: true).limit(1);
      QuerySnapshot snapshot = await randomReference.getDocuments();
      documents = snapshot.documents ?? [];

      if (documents.isEmpty) {
        Query randomReference = reference.where("random", isGreaterThanOrEqualTo: number)
            .orderBy("random", descending: true).limit(1);
        snapshot = await randomReference.getDocuments();
        documents = snapshot.documents ?? [];
      }
    } else {
      QuerySnapshot snapshot = await reference.getDocuments();
      documents = snapshot.documents ?? [];
    }

    List<MapEntry<String, Chapter>> entries = documents.map((document) =>
        MapEntry<String, Chapter>(document.documentID, Chapter.fromRaw(document.data))).toList();
    return Map.fromEntries(entries);
  }

  Future<dynamic> update(String key, Chapter chapter) {
    DocumentReference reference = _database.collection("chapters").document(key);
    return reference.updateData(chapter.toJson());
  }

  Future<dynamic> delete(String key) async {
    DocumentReference reference = _database.collection("chapters").document(key);
    return reference.delete();
  }

  Stream<MapEntry<String, Chapter>> valueStream(String key) {
    DocumentReference reference = _database.collection("chapters").document(key);
    return reference.snapshots().map((snapshot) => snapshot?.data != null
        ? MapEntry(snapshot.documentID, Chapter.fromRaw(snapshot.data)) : null);
  }

  Stream<Map<String, Chapter>> collectionStream({String source, int limit}) {
    Query reference = _database.collection("chapters");
    if (source != null) reference = reference.where("source", isEqualTo: source);
    if (limit != null) reference = reference.orderBy("hearts", descending: true).limit(limit);
    return reference.snapshots().map((snapshot) {
      List<DocumentSnapshot> documents = snapshot.documents ?? [];
      List<MapEntry<String, Chapter>> entries = documents.map((document) =>
          MapEntry<String, Chapter>(document.documentID, Chapter.fromRaw(document.data))).toList();
      return Map.fromEntries(entries);
    });
  }

  Future<dynamic> heart(String key, bool heart) {
    DocumentReference reference = _database.collection("chapters").document(key);
    return _database.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      final Chapter chapter = Chapter.fromRaw(snapshot.data);
      chapter.hearts = heart ? (chapter.hearts + 1) : (chapter.hearts - 1);
      return transaction.update(reference, chapter.toJson());
    });
  }
}