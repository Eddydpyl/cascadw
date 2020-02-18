import 'package:cloud_firestore/cloud_firestore.dart';

import 'repositories/book_repository.dart';
import 'repositories/bookmark_repository.dart';
import 'repositories/heart_repository.dart';
import 'repositories/chapter_repository.dart';
import 'repositories/user_repository.dart';

class DatabaseManager {
  final Firestore _database;

  DatabaseManager(this._database);

  BookRepository bookRepository() => BookRepository(_database);

  BookmarkRepository bookmarkRepository(String uid) => BookmarkRepository(_database, uid);

  HeartRepository heartRepository(String uid) => HeartRepository(_database, uid);

  ChapterRepository chapterRepository() => ChapterRepository(_database);

  UserRepository userRepository() => UserRepository(_database);
}