import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../managers/auth_manager.dart';
import '../managers/database_manager.dart';
import '../blocs/session_bloc.dart';

class SessionProvider<T> extends StatelessWidget {
  final Widget child;
  final AuthManager auth;
  final DatabaseManager database;

  SessionProvider({
    @required this.child,
    @required this.auth,
    @required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Session"),
      inherited: SessionInherited(
        child: child,
        bloc: SessionBloc(auth, database),
      ),
    );
  }

  static SessionBloc sessionBloc(BuildContext context) =>
      BaseProvider.bloc<SessionInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<SessionInherited>(context);
}

// ignore: must_be_immutable
class SessionInherited extends BaseInherited<SessionBloc> {

  SessionInherited({
    @required Widget child,
    @required SessionBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}