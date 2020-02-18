import 'dart:async';

import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/state_bloc.dart';
import '../blocs/chapter_bloc.dart';
import '../managers/database_manager.dart';

class ChapterProvider extends StatelessWidget {
  final Widget child;
  final StateBloc stateBloc;
  final DatabaseManager database;
  final String chapterKey;

  ChapterProvider({
    @required this.child,
    @required this.stateBloc,
    @required this.database,
    @required this.chapterKey,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Chapter"),
      inherited: ChapterInherited(
        child: child,
        bloc: ChapterBloc(database),
      ),
      initialize: (ChapterBloc bloc, Set<StreamSubscription> subscriptions) {
        subscriptions.add(stateBloc.userKeyStream
            .listen((key) => bloc.userKeySink.add(key)));
        bloc.chapterKeySink.add(chapterKey);
      },
    );
  }

  static ChapterBloc chapterBloc(BuildContext context) =>
      BaseProvider.bloc<ChapterInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<ChapterInherited>(context);
}

// ignore: must_be_immutable
class ChapterInherited extends BaseInherited<ChapterBloc> {

  ChapterInherited({
    @required Widget child,
    @required ChapterBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}