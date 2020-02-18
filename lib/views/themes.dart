import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get cascadw {
    return ThemeData(
      fontFamily: "Raleway",
      // TODO: Remove the two lines below when the bug is fixed.
      // https://github.com/flutter/flutter/pull/39624
      buttonTheme: ButtonThemeData(minWidth: 10),
      textTheme: TextTheme(button: TextStyle(fontSize: 10)),
    );
  }
}