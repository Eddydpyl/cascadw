import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../managers/database_manager.dart';
import '../models/chapter.dart';
import '../models/bookmark.dart';
import '../models/heart.dart';
import '../models/user.dart';

class ChapterBloc extends BaseBloc {
  final DatabaseManager _databaseManager;

  LenientSubject<String> _userKey;
  LenientSubject<String> _chapterKey;
  LenientSubject<MapEntry<String, Chapter>> _chapter;
  LenientSubject<Map<String, Chapter>> _top;
  LenientSubject<MapEntry<String, Chapter>> _random;
  LenientSubject<MapEntry<String, AppUser>> _user;
  LenientSubject<bool> _bookmark;
  LenientSubject<bool> _heart;

  ChapterBloc(DatabaseManager databaseManager)
      : _databaseManager = databaseManager;

  /// Returns an [Stream] of the chapter.
  Observable<MapEntry<String, Chapter>> get chapterStream => _chapter.stream;

  /// Returns an [Stream] of the top three next chapters.
  Observable<Map<String, Chapter>> get topStream => _top.stream;

  /// Returns an [Stream] of a completely random chapter.
  Observable<MapEntry<String, Chapter>> get randomStream => _random.stream;

  /// Returns an [Stream] of the author of the chapter.
  Observable<MapEntry<String, AppUser>> get userStream => _user.stream;

  /// Consumes the key of the current user (REQUIRED).
  Sink<String> get userKeySink => _userKey.sink;

  /// Consumes the key of the book (REQUIRED).
  Sink<String> get chapterKeySink => _chapterKey.sink;

  /// Consumes whether the chapter should be bookmarked.
  Sink<bool> get bookmarkSink => _bookmark.sink;

  /// Consumes whether the chapter should be hearted.
  Sink<bool> get heartSink => _heart.sink;


  @override
  void initialize() {
    super.initialize();
    _userKey = LenientSubject(ignoreRepeated: true);
    _chapterKey = LenientSubject(ignoreRepeated: false);
    _chapter = LenientSubject(ignoreRepeated: false);
    _top = LenientSubject(ignoreRepeated: false);
    _random = LenientSubject(ignoreRepeated: false);
    _user = LenientSubject(ignoreRepeated: false);
    _bookmark = LenientSubject(ignoreRepeated: true);
    _heart = LenientSubject(ignoreRepeated: true);

    _userKey.stream.listen((String key) async {
      if (key != null && _chapterKey.value != null)
        _retrieveData(_databaseManager, _chapterKey.value, key);
    });
    _chapterKey.stream.listen((String key) async {
      if (key != null && _userKey.value != null)
        _retrieveData(_databaseManager, key, _userKey.value);
    });
    _bookmark.stream.listen((bool bookmark) async {
      if (bookmark != null && _chapterKey.value != null
          && _userKey.value != null && _chapter.value != null) {
        Map<String, Bookmark> bookmarks = await _databaseManager
            .bookmarkRepository(_userKey.value).readAll(chapter: _chapterKey.value);
        if (bookmark && (bookmarks?.isEmpty ?? true)) {
          Bookmark bookmark = Bookmark(book: _chapter.value.value.book, chapter: _chapterKey.value);
          _databaseManager.bookmarkRepository(_userKey.value).create(bookmark);
        } else if (!bookmark && (bookmarks?.isNotEmpty ?? false)) {
          _databaseManager.bookmarkRepository(_userKey.value).delete(bookmarks.keys.first);
        }
      }
    });
    _heart.stream.listen((bool hearted) async {
      if (hearted != null && _chapterKey.value != null
          && _userKey.value != null && _chapter.value != null) {
        Map<String, Heart> hearts = await _databaseManager
            .heartRepository(_userKey.value).readAll(chapter: _chapterKey.value);
        if (hearted && (hearts?.isEmpty ?? true)) {
          Heart heart = Heart(book: _chapter.value.value.book, chapter: _chapterKey.value);
          _databaseManager.heartRepository(_userKey.value).create(heart);
          _databaseManager.chapterRepository().heart(_chapterKey.value, hearted);
        } else if (!hearted && (hearts?.isNotEmpty ?? false)) {
          _databaseManager.heartRepository(_userKey.value).delete(hearts.keys.first);
          _databaseManager.chapterRepository().heart(_chapterKey.value, hearted);
        }
      }
    });
  }

  void _retrieveData(DatabaseManager databaseManager,
      String chapterKey, String userKey) async {
    Chapter chapter = await databaseManager
        .chapterRepository().read(chapterKey);
    _top.add(await databaseManager.chapterRepository()
        .readAll(source: chapterKey, limit: 3) ?? Map());
    Map<String, Chapter> random = await databaseManager.chapterRepository()
        .readAll(source: chapterKey, random: true);
    if (random?.isNotEmpty ?? false)
      _random.add(random.entries.first);
    else _random.add(null);

    AppUser user = await databaseManager.userRepository().read(chapter.uid);
    _user.add(MapEntry(chapter.uid, user));

    // Retrieve fields related to current user.
    Map<String, Bookmark> bookmarks = await databaseManager
        .bookmarkRepository(userKey).readAll(chapter: chapterKey);
    chapter.bookmarked = bookmarks?.isNotEmpty ?? false;
    Map<String, Heart> hearts = await databaseManager
        .heartRepository(userKey).readAll(chapter: chapterKey);
    chapter.hearted = hearts?.isNotEmpty ?? false;
    _chapter.add(MapEntry(chapterKey, chapter));
  }

  @override
  Future dispose() async {
    List<Future> futures = List();
    futures.add(_userKey.close());
    futures.add(_chapterKey.close());
    futures.add(_chapter.close());
    futures.add(_top.close());
    futures.add(_random.close());
    futures.add(_user.close());
    futures.add(_bookmark.close());
    futures.add(_heart.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}