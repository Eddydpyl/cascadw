import 'package:flutter/material.dart';

class DarkBar extends StatelessWidget{
  final Widget child;
  final double height;

  DarkBar({@required this.child, @required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50.0)),
      child: Container(
        height: height,
        color: Colors.black,
        child: Align(
          alignment: Alignment(0, 0.5),
          child: child,
        ),
      ),
    );
  }
}

class InitialsText extends StatelessWidget {
  final String text;
  final Color color;

  InitialsText(this.text, [this.color = Colors.black]);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase(),
      style: TextStyle(color: color),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }
}


