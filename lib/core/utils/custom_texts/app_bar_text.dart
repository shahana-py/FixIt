import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const AppBarTitle({
    Key? key,
    required this.text,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.white, // Add "const" before Color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
