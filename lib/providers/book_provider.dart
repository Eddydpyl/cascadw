import 'dart:async';

import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/book_bloc.dart';
import '../managers/database_manager.dart';

class BookProvider extends StatelessWidget {
  final Widget child;
  final DatabaseManager database;
  final String bookKey;

  BookProvider({
    @required this.child,
    @required this.database,
    @required this.bookKey,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Book"),
      inherited: BookInherited(
        child: child,
        bloc: BookBloc(database),
      ),
      initialize: (BookBloc bloc, Set<StreamSubscription> subscriptions) {
        bloc.bookKeySink.add(bookKey);
      },
    );
  }

  static BookBloc bookBloc(BuildContext context) =>
      BaseProvider.bloc<BookInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<BookInherited>(context);
}

// ignore: must_be_immutable
class BookInherited extends BaseInherited<BookBloc> {

  BookInherited({
    @required Widget child,
    @required BookBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}