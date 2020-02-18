import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/auth_manager.dart';
import '../managers/database_manager.dart';
import '../managers/storage_manager.dart';
import '../managers/preference_manager.dart';

class ApplicationProvider extends InheritedWidget {
  final AuthManager _authManager;
  final DatabaseManager _databaseManager;
  final StorageManager _storageManager;
  final PreferenceManager _pref;

  ApplicationProvider({
    Key key,
    @required Widget child,
    @required Firestore database,
    @required FirebaseAuth auth,
    @required FirebaseStorage storage,
    @required SharedPreferences preferences,
  })  : _authManager = AuthManager(auth),
        _databaseManager = DatabaseManager(database),
        _storageManager = StorageManager(storage),
        _pref = PreferenceManager(preferences),
        super(key: key, child: child);

  static AuthManager auth(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ApplicationProvider)
      as ApplicationProvider)._authManager;

  static DatabaseManager database(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ApplicationProvider)
      as ApplicationProvider)._databaseManager;

  static StorageManager storage(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ApplicationProvider)
      as ApplicationProvider)._storageManager;

  static PreferenceManager preferences(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ApplicationProvider)
      as ApplicationProvider)._pref;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}