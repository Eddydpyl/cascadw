import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user.dart';
import '../managers/auth_manager.dart';
import '../managers/database_manager.dart';

class SessionMode {
  static const int SIGN_IN = 0;
  static const int SIGN_UP = 1;
  static const int RESET = 2;
}

class SessionBloc extends BaseBloc {
  final AuthManager _authManager;
  final DatabaseManager _databaseManager;

  LenientSubject<int> _mode;
  LenientSubject<String> _name;
  LenientSubject<String> _email;
  LenientSubject<String> _password;

  SessionBloc(AuthManager authManager, DatabaseManager databaseManager)
      : _authManager = authManager, _databaseManager = databaseManager;

  /// Returns a [Stream] of the current mode.
  Observable<int> get modeStream => _mode.stream;

  /// Consumes a [int] used for indicating whether we sign up, sign in or reset.
  Sink<int> get modeSink => _mode.sink;

  /// Consumes a [String] used to sign up.
  Sink<String> get nameSink => _name.sink;

  /// Consumes a [String] used to sign up, sign in or reset.
  Sink<String> get emailSink => _email.sink;

  /// Consumes a [String] used to sign up or sign in.
  Sink<String> get passwordSink => _password.sink;


  @override
  void initialize() {
    super.initialize();
    _mode = LenientSubject(ignoreRepeated: false);
    _name = LenientSubject(ignoreRepeated: false);
    _email = LenientSubject(ignoreRepeated: false);
    _password = LenientSubject(ignoreRepeated: false);

    _mode.add(SessionMode.SIGN_IN);
    _mode.stream.listen((int mode) => _emptyFields());
    _name.stream.listen((String name) {
      if (_mode.value == SessionMode.SIGN_UP)
        _signUp(_authManager, _databaseManager, name, _email.value, _password.value);
    });
    _email.stream.listen((String email) {
      if (_mode.value == SessionMode.SIGN_IN)
        _signIn(_authManager, email, _password.value);
      else if (_mode.value == SessionMode.SIGN_UP)
        _signUp(_authManager, _databaseManager, _name.value, email, _password.value);
      else if (_mode.value == SessionMode.RESET)
        _reset(_authManager, email);
    });
    _password.stream.listen((String password) {
      if (_mode.value == SessionMode.SIGN_IN)
        _signIn(_authManager, _email.value, password);
      else if (_mode.value == SessionMode.SIGN_UP)
        _signUp(_authManager, _databaseManager, _name.value, _email.value, password);
    });
  }

  void _signIn(AuthManager auth, String email, String password) {
    if (email == null) return;
    if (password == null) return;
    _emptyFields();

    auth.signIn(email, password).catchError((exception) {
      if (exception.code == "ERROR_INVALID_EMAIL")
        forwardException(FailedException("The email address is not valid."));
      else if (exception.code == "ERROR_WRONG_PASSWORD")
        forwardException(FailedException("Either the email or password are incorrect."));
      else if (exception.code == "ERROR_USER_NOT_FOUND")
        forwardException(FailedException("Either the email or password are incorrect."));
      else if (exception.code == "ERROR_USER_DISABLED")
        forwardException(FailedException("Your user has been disabled by an administrator."));
      else forwardException(FailedException("There was an issue and you could not sign in."));
    });
  }

  void _signUp(AuthManager auth, DatabaseManager database,
      String name, String email, String password) {
    if (name == null) return;
    if (email == null) return;
    if (password == null) return;
    _emptyFields();

    auth.signUp(email, password).then((data) {
      AppUser user = AppUser(email: email, name: name);
      database.userRepository().create(data.uid, user);
    }).catchError((PlatformException exception) {
      if (exception.code == "ERROR_WEAK_PASSWORD")
        forwardException(FailedException("The password must be at least 6 characters long."));
      else if (exception.code == "ERROR_INVALID_EMAIL")
        forwardException(FailedException("The email address is not valid."));
      else if (exception.code == "ERROR_WEAK_PASSWORD")
        forwardException(FailedException("The email address is already in use."));
      else forwardException(FailedException("There was an issue and you could not sign up."));
    });
  }

  void _reset(AuthManager auth, String email) {
    if (email == null) return;
    _emptyFields();

    auth.sendPasswordResetEmail(email)
        .then((_) => forwardException(SuccessfulException("A password reset link has been sent to your email.")))
        .catchError((_) => forwardException(FailedException("An account with the provided email does not exist.")));
  }

  void _emptyFields() {
    _name.add(null);
    _email.add(null);
    _password.add(null);
  }

  @override
  Future dispose() async {
    _mode.close();
    _name.close();
    _email.close();
    _password.close();
    super.dispose();
  }
}