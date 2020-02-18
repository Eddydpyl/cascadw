import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user.dart';
import '../models/chapter.dart';
import '../models/bookmark.dart';
import '../models/heart.dart';
import '../managers/database_manager.dart';

class BookmarksBloc extends BaseBloc {
  final DatabaseManager _databaseManager;

  LenientSubject<String> _userKey;
  LenientSubject<String> _bookKey;
  LenientSubject<Map<String, Bookmark>> _bookmarks;
  LenientSubject<Map<String, Chapter>> _chapters;
  LenientSubject<Map<String, AppUser>> _users;
  LenientSubject<String> _bookmark;
  LenientSubject<String> _heart;

  StreamSubscription _subscription;

  BookmarksBloc(DatabaseManager databaseManager)
      : _databaseManager = databaseManager;

  /// Returns an [Stream] of the bookmarks.
  Observable<Map<String, Bookmark>> get bookmarksStream => _bookmarks.stream;

  /// Returns an [Stream] of the chapters.
  Observable<Map<String, Chapter>> get chaptersStream => _chapters.stream;

  /// Returns an [Stream] of the users.
  Observable<Map<String, AppUser>> get usersStream => _users.stream;

  /// Consumes the key of the selected book (REQUIRED).
  Sink<String> get bookKeySink => _bookKey.sink;

  /// Consumes the key of the current user (REQUIRED).
  Sink<String> get userKeySink => _userKey.sink;

  /// Consumes the chapter that should be bookmarked.
  Sink<String> get bookmarkSink => _bookmark.sink;

  /// Consumes the chapter that should be hearted.
  Sink<String> get heartSink => _heart.sink;

  @override
  void initialize() {
    super.initialize();
    _userKey = LenientSubject(ignoreRepeated: true);
    _bookKey = LenientSubject(ignoreRepeated: true);
    _bookmarks = LenientSubject(ignoreRepeated: false);
    _chapters = LenientSubject(ignoreRepeated: false);
    _users = LenientSubject(ignoreRepeated: false);
    _bookmark = LenientSubject(ignoreRepeated: false);
    _heart = LenientSubject(ignoreRepeated: false);

    _userKey.stream.listen((String key) =>
        _retrieveData(_databaseManager, key, _bookKey.value));
    _bookKey.stream.listen((String key) =>
        _retrieveData(_databaseManager, _userKey.value, key));
    _bookmark.stream.listen((String chapter) async {
      if (chapter != null && _userKey.value != null && _bookKey.value != null) {
        Map<String, Bookmark> bookmarks = await _databaseManager
            .bookmarkRepository(_userKey.value).readAll(chapter: chapter);
        if (bookmarks?.isEmpty ?? true) {
          Bookmark bookmark = Bookmark(book: _bookKey.value, chapter: chapter);
          _databaseManager.bookmarkRepository(_userKey.value).create(bookmark);
        } else _databaseManager.bookmarkRepository(_userKey.value).delete(bookmarks.keys.first);
      }
    });
    _heart.stream.listen((String chapter) async {
      if (chapter != null && _userKey.value != null && _bookKey.value != null) {
        Map<String, Heart> hearts = await _databaseManager
            .heartRepository(_userKey.value).readAll(chapter: chapter);
        if (hearts?.isEmpty ?? true) {
          Heart heart = Heart(book: _bookKey.value, chapter: chapter);
          _databaseManager.heartRepository(_userKey.value).create(heart);
          _databaseManager.chapterRepository().heart(chapter, true);
        } else {
          _databaseManager.heartRepository(_userKey.value).delete(hearts.keys.first);
          _databaseManager.chapterRepository().heart(chapter, false);
        }

        // Update the fields related to current user.
        Map<String, Chapter> chapters = _chapters.value ?? Map();
        chapters[chapter].hearted = hearts?.isEmpty ?? true;
        _chapters.add(chapters);
      }
    });
  }

  void _retrieveData(DatabaseManager databaseManager,
      String userKey, String bookKey) async {
    if (userKey != null && bookKey != null) {
      _subscription?.cancel();
      _subscription = databaseManager.bookmarkRepository(userKey)
          .collectionStream(book: bookKey).listen((bookmarks) async {
        Map<String, Chapter> chapters = _chapters.value ?? Map();
        Map<String, AppUser> users = _users.value ?? Map();
        for (String key in bookmarks.keys ?? []) {
          Bookmark bookmark = bookmarks[key];
          if (!chapters.containsKey(bookmark.chapter)) {
            Chapter chapter = await databaseManager
                .chapterRepository().read(bookmark.chapter);
            if (chapter != null) {
              chapters[bookmark.chapter] = chapter;
              if (!users.containsKey(chapter.uid)) {
                AppUser user = await databaseManager.userRepository().read(chapter.uid);
                users[chapter.uid] = user;
              }
            }
          }

          // Retrieve fields related to current user.
          Map<String, Heart> hearts = await databaseManager
              .heartRepository(userKey).readAll(chapter: bookmark.chapter);
          if (chapters[bookmark.chapter] != null)
            chapters[bookmark.chapter].hearted = hearts?.isNotEmpty ?? false;
        }

        _bookmarks.add(bookmarks);
        _chapters.add(chapters);
        _users.add(users);
      });
    }
  }

  @override
  Future dispose() async {
    List<Future> futures = List();
    futures.add(_subscription?.cancel() ?? Future.value());
    futures.add(_userKey.close());
    futures.add(_bookKey.close());
    futures.add(_bookmarks.close());
    futures.add(_chapters.close());
    futures.add(_users.close());
    futures.add(_bookmark.close());
    futures.add(_heart.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}
