import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'blocs/state_bloc.dart';
import 'providers/application_provider.dart';
import 'providers/state_provider.dart';
import 'views/pages/book_page.dart';
import 'views/pages/session_page.dart';
import 'views/themes.dart';

void main() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(App(preferences));
}

class App extends StatelessWidget {
  final SharedPreferences preferences;

  App(this.preferences);

  @override
  Widget build(BuildContext context) {
    return ApplicationProvider(
      database: Firestore(app: FirebaseApp.instance),
      auth: FirebaseAuth.fromApp(FirebaseApp.instance),
      storage: FirebaseStorage(),
      preferences: preferences,
      child: Builder(
        builder: (BuildContext context) {
          return StateProvider(
            auth: ApplicationProvider.auth(context),
            child: Builder(
              builder: (BuildContext context) {
                final StateBloc stateBloc = StateProvider.stateBloc(context);
                return StreamBuilder(
                  stream: stateBloc.userKeyStream,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    final String uid = snapshot.data;
                    return MaterialApp(
                      title: "Cascadw",
                      theme: CustomTheme.cascadw,
                      home: uid == null
                          ? SplashScreen() : uid.isNotEmpty
                          ? BookPage("beta_book")
                          : SessionPage(),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: 250.0,
          height: 250.0,
          child: ClipPolygon(
            borderRadius: 15.0,
            sides: 6,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/initials.png",
                width: 150.0,
                height: 150.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
