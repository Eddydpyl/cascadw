import 'dart:async';

import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/state_bloc.dart';
import '../blocs/bookmarks_bloc.dart';
import '../managers/database_manager.dart';

class BookmarksProvider extends StatelessWidget {
  final Widget child;
  final StateBloc stateBloc;
  final DatabaseManager database;
  final String bookKey;

  BookmarksProvider({
    @required this.child,
    @required this.stateBloc,
    @required this.database,
    @required this.bookKey,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Bookmarks"),
      inherited: BookmarksInherited(
        child: child,
        bloc: BookmarksBloc(database),
      ),
      initialize: (BookmarksBloc bloc, Set<StreamSubscription> subscriptions) {
        subscriptions.add(stateBloc.userKeyStream
            .listen((key) => bloc.userKeySink.add(key)));
        bloc.bookKeySink.add(bookKey);
      },
    );
  }

  static BookmarksBloc bookmarksBloc(BuildContext context) =>
      BaseProvider.bloc<BookmarksInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<BookmarksInherited>(context);
}

// ignore: must_be_immutable
class BookmarksInherited extends BaseInherited<BookmarksBloc> {

  BookmarksInherited({
    @required Widget child,
    @required BookmarksBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}