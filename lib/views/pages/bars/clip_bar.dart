import 'package:flutter/material.dart';

class ClipBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  ClipBar([this.title]);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40.0),
      ),
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.only(left: 16.0, top: 20.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: this.title != null ? Text(
            this.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ) : null,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(1.55 * kToolbarHeight);
}
