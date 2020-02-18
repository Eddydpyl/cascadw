import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../managers/auth_manager.dart';

class StateBloc extends BaseBloc {
  final AuthManager _authManager;

  LenientSubject<String> _userKey;

  StateBloc(AuthManager authManager) : _authManager = authManager;

  /// Returns a [Stream] of the logged in user's key.
  Observable<String> get userKeyStream => _userKey.stream;

  @override
  void initialize() {
    super.initialize();
    _userKey = LenientSubject();

    _authManager.onAuthStateChanged()
        .listen((FirebaseUser user) =>
        _userKey.add(user?.uid ?? ""));
  }

  @override
  Future dispose() {
    List<Future> futures = List();
    futures.add(_userKey.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}