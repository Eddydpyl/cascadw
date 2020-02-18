import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../managers/auth_manager.dart';
import '../blocs/state_bloc.dart';

class StateProvider extends StatelessWidget {
  final Widget child;
  final AuthManager auth;

  StateProvider({
    @required this.child,
    @required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("State"),
      inherited: StateInherited(
        child: child,
        bloc: StateBloc(auth),
      ),
    );
  }

  static StateBloc stateBloc(BuildContext context) =>
      BaseProvider.bloc<StateInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<StateInherited>(context);
}

// ignore: must_be_immutable
class StateInherited extends BaseInherited<StateBloc> {

  StateInherited({
    @required Widget child,
    @required StateBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}