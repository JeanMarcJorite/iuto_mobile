import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double elevation;
  final double fontSize;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.elevation,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
                elevation: WidgetStateProperty.all(elevation),
                backgroundColor: WidgetStateProperty.all(Colors.blue.shade400),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ))),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}