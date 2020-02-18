import 'package:flutter/material.dart';

class SessionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double factor = size.width / 10;
    path.moveTo(0.0, factor);
    path.quadraticBezierTo(factor * 1.5, 0.0, factor * 3.5, factor);
    path.lineTo(factor * 12.5, factor * 6.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) =>  true;
}
