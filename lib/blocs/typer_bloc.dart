import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';

import '../models/chapter.dart';
import '../models/bookmark.dart';
import '../managers/database_manager.dart';

class TyperBloc extends BaseBloc {
  final DatabaseManager _databaseManager;

  LenientSubject<Chapter> _create;
  LenientSubject<MapEntry<String, Chapter>> _update;
  LenientSubject<String> _delete;

  TyperBloc(DatabaseManager databaseManager)
      : _databaseManager = databaseManager;

  /// Consumes a [Chapter] and uses it to create an instance in the database.
  Sink<Chapter> get createSink => _create.sink;

  /// Consumes a [MapEntry] and uses it to update the instance in the database.
  Sink<MapEntry<String, Chapter>> get updateSink => _update.sink;

  /// Consumes a [String] and uses it to delete the instance in the database.
  Sink<String> get deleteSink => _delete.sink;


  @override
  void initialize() {
    super.initialize();
    _create = LenientSubject(ignoreRepeated: false);
    _update = LenientSubject(ignoreRepeated: false);
    _delete = LenientSubject(ignoreRepeated: false);

    _create.stream.listen((Chapter chapter) async {
      if (chapter != null) {
        String key = await _databaseManager.chapterRepository().create(chapter);
        Bookmark bookmark = Bookmark(book: chapter.book, chapter: key);
        _databaseManager.bookmarkRepository(chapter.uid).create(bookmark);
        forwardException(SuccessfulException("Chapter Created", true));
      }
    });
    _update.stream.listen((MapEntry<String, Chapter> entry) async {
      if (entry != null) {
        Map<String, Chapter> chapters = await _databaseManager
            .chapterRepository().readAll(source: entry.key);
        if (chapters?.isEmpty ?? true) {
          _databaseManager.chapterRepository().update(entry.key, entry.value);
          forwardException(SuccessfulException("Chapter Updated", true));
        } else forwardException(ForbiddenException("You can no longer update"
            " this chapter, as there are others that branch from it. Message"
            " an administrator if you really need to make some changes."));
      }
    });
    _delete.stream.listen((String key) async {
      if (key != null) {
        Map<String, Chapter> chapters = await _databaseManager
            .chapterRepository().readAll(source: key);
        if (chapters?.isEmpty ?? true) {
          _databaseManager.chapterRepository().delete(key);
          forwardException(SuccessfulException("Chapter Deleted", false));
        } else forwardException(ForbiddenException("You can no longer delete"
            " this chapter, as there are others that branch from it. Message"
            " an administrator if there's a very good reason to delete it."));
      }
    });
  }

  @override
  Future dispose() async {
    List<Future> futures = List();
    futures.add(_create.close());
    futures.add(_update.close());
    futures.add(_delete.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}
