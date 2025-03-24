import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;
  final bool obscureText;
  final bool iconObscureInit;
  final bool showIconObscure;
  final bool isNumeric;
  final bool readOnly;
  final VoidCallback? onTap;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    required this.obscureText,
    this.iconObscureInit = false,
    this.showIconObscure = false,
    this.isNumeric = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;
  late Icon _iconObscure;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _iconObscure = _obscureText
        ? const Icon(Icons.visibility_off_outlined)
        : const Icon(Icons.visibility_outlined);
  }

  void toggleIcon() {
    setState(() {
      _obscureText = !_obscureText;
      _iconObscure = _obscureText
          ? const Icon(Icons.visibility_off_outlined)
          : const Icon(Icons.visibility_outlined);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.text,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade900,
        ),
        prefixIcon: widget.icon,
        suffixIcon: widget.showIconObscure
            ? GestureDetector(
                onTap: toggleIcon,
                child: _iconObscure,
              )
            : null,
      ),
    );
  }
}