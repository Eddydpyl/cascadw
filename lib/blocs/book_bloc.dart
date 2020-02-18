import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/book.dart';
import '../managers/database_manager.dart';

class BookBloc extends BaseBloc {
  final DatabaseManager _databaseManager;

  LenientSubject<String> _bookKey;
  LenientSubject<MapEntry<String, Book>> _book;

  BookBloc(DatabaseManager databaseManager)
      : _databaseManager = databaseManager;

  /// Returns an [Stream] of the book.
  Observable<MapEntry<String, Book>> get bookStream => _book.stream;

  /// Consumes the key of the book (REQUIRED).
  Sink<String> get bookKeySink => _bookKey.sink;

  @override
  void initialize() {
    super.initialize();
    _bookKey = LenientSubject(ignoreRepeated: true);
    _book = LenientSubject(ignoreRepeated: false);

    _bookKey.stream.listen((String key) async {
      if (key != null) {
        Book book = await _databaseManager.bookRepository().read(key);
        _book.add(MapEntry(key, book));
      }
    });
  }

  @override
  Future dispose() async {
    List<Future> futures = List();
    futures.add(_bookKey.close());
    futures.add(_book.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}
