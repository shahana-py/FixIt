import 'package:flutter/material.dart';

class MainText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const MainText({
    Key? key,
    required this.text,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(), // Converts text to uppercase
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w500, // Medium weight
        color: Colors.black,
      ),
    );
  }
}
