import 'package:flutter/material.dart';

class RoundClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path p = Path();
    p.moveTo(0, size.height);
    p.quadraticBezierTo(10, size.height - 10, 10, size.height - 30);
    p.moveTo(10, size.height - 30);
    p.quadraticBezierTo(10, 0, 30, 0);
    p.lineTo(size.width - 30, 0);
    p.quadraticBezierTo(size.width - 10, 0, size.width - 10, size.height - 30);
    p.quadraticBezierTo(
        size.width - 10, size.height - 10, size.width, size.height);
    p.lineTo(0, size.height);
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) =>  true;
}
