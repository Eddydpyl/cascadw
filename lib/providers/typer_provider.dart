import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/typer_bloc.dart';
import '../managers/database_manager.dart';

class TyperProvider extends StatelessWidget {
  final Widget child;
  final DatabaseManager database;

  TyperProvider({
    @required this.child,
    @required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Typer"),
      inherited: TyperInherited(
        child: child,
        bloc: TyperBloc(database),
      ),
    );
  }

  static TyperBloc typerBloc(BuildContext context) =>
      BaseProvider.bloc<TyperInherited>(context);

  static PublishSubject<BaseException> exception(BuildContext context) =>
      BaseProvider.exception<TyperInherited>(context);
}

// ignore: must_be_immutable
class TyperInherited extends BaseInherited<TyperBloc> {

  TyperInherited({
    @required Widget child,
    @required TyperBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}