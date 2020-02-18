import 'package:flutter/material.dart';

class EmptyBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.maxFinite,
      height: 0.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(0.0);
}
