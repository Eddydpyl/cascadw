import 'package:flutter/material.dart';

class TyperBar extends StatelessWidget {
  final String text;

  TyperBar(this.text);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SliverAppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
        ),
      ),
      backgroundColor: Colors.black,
      expandedHeight: width > height ? 175.0 : 225.0,
      centerTitle: true,
      floating: false,
      pinned: true,
      title: Text(
        "Previous Chapter",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 88.0, 16.0, 16.0),
          child: Text(
            "... $text",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
