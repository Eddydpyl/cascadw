import 'dart:async';

import 'package:darter_provider/darter_provider.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/profile_bloc.dart';
import '../blocs/uploader_bloc.dart';
import '../managers/auth_manager.dart';
import '../managers/database_manager.dart';
import '../managers/storage_manager.dart';

class ProfileProvider extends StatelessWidget {
  final Widget child;
  final AuthManager auth;
  final DatabaseManager database;
  final StorageManager storage;
  final String userKey;

  ProfileProvider({
    @required this.child,
    @required this.auth,
    @required this.database,
    @required this.storage,
    @required this.userKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBaseProvider.create(
      key: Key("Profile"),
      inherited: ProfileInherited(
        child: child,
        blocs: {
          "profileBloc": ProfileBloc(auth, database),
          "uploaderBloc": UploaderBloc(storage),
        },
      ),
      initialize: (Map<String, BaseBloc> blocs, Set<StreamSubscription> subscriptions) {
        ProfileBloc profileBloc = blocs["profileBloc"];
        profileBloc.userKeySink.add(userKey);
      },
    );
  }

  static ProfileBloc profileBloc(BuildContext context) =>
      MultiBaseProvider.bloc<ProfileInherited>(context, "profileBloc");

  static UploaderBloc uploaderBloc(BuildContext context) =>
      MultiBaseProvider.bloc<ProfileInherited>(context, "uploaderBloc");

  static PublishSubject<BaseException> exception(BuildContext context) =>
      MultiBaseProvider.exception<ProfileInherited>(context);
}

// ignore: must_be_immutable
class ProfileInherited extends MultiBaseInherited {

  ProfileInherited({
    @required Widget child,
    @required Map<String, BaseBloc> blocs,
  }) : super(child: child, blocs: blocs);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}