import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user.dart';
import '../managers/auth_manager.dart';
import '../managers/database_manager.dart';

class ProfileBloc extends BaseBloc {
  final AuthManager _authManager;
  final DatabaseManager _databaseManager;

  LenientSubject<String> _userKey;
  LenientSubject<AppUser> _update;
  LenientSubject<MapEntry<String, String>> _password;
  LenientSubject<MapEntry<String, AppUser>> _user;

  ProfileBloc(AuthManager authManager, DatabaseManager databaseManager)
      : _authManager = authManager, _databaseManager = databaseManager;

  /// Returns an [Stream] of the user.
  Observable<MapEntry<String, AppUser>> get userStream => _user.stream;

  /// Consumes data to update the user.
  Sink<AppUser> get updateSink => _update.sink;

  /// Consumes a [MapEntry] to update the user's password.
  Sink<MapEntry<String, String>> get passwordSink => _password.sink;

  /// Consumes the key of the user (REQUIRED).
  Sink<String> get userKeySink => _userKey.sink;


  @override
  void initialize() {
    super.initialize();
    _userKey = LenientSubject(ignoreRepeated: true);
    _update = LenientSubject(ignoreRepeated: false);
    _password = LenientSubject(ignoreRepeated: false);
    _user = LenientSubject(ignoreRepeated: false);

    _userKey.stream.listen((String key) async {
      if (key != null) {
        AppUser user = await _databaseManager.userRepository().read(key);
        _user.add(MapEntry(key, user));
      }
    });
    _update.stream.listen((AppUser update) {
      if (update != null && _userKey.value != null){
        if (update.email?.isNotEmpty ?? false) {
          _authManager.updateEmail(update.email)
              .then((_) => _databaseManager.userRepository().update(_userKey.value, update)
              .then((_) => forwardException(SuccessfulException("Your profile has been updated."))))
              .catchError((exception) {
            if (exception.code == "ERROR_INVALID_EMAIL")
              forwardException(FailedException("The email is not valid."));
            else if (exception.code == "ERROR_EMAIL_ALREADY_IN_USE")
              forwardException(FailedException("The email is already in use by another user."));
            else forwardException(FailedException("An unexpected error occurred."));
          });
        } else _databaseManager.userRepository().update(_userKey.value, update)
            .then((_) => forwardException(SuccessfulException("Your profile has been updated.")));
      }
    });
    _password.stream.listen((MapEntry<String, String> entry) async {
      if (entry != null){
        _authManager.reAuth(entry.key).then((bool success) {
          if (!success) return forwardException(FailedException("Your password is not correct."));
          _authManager.updatePassword(entry.value)
              .then((_) => forwardException(FailedException("Your password has been updated.")))
              .catchError((exception) {
            if (exception.code == "ERROR_WEAK_PASSWORD")
              forwardException(FailedException("The new password must be at least 6 characters long."));
            else forwardException(FailedException("An unexpected error occurred."));
          });
        }).catchError((_) => forwardException(FailedException("Your password is not correct.")));
      }
    });
  }

  @override
  Future dispose() async {
    List<Future> futures = List();
    futures.add(_userKey.close());
    futures.add(_update.close());
    futures.add(_password.close());
    futures.add(_user.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}
