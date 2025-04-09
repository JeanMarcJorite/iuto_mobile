import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;
  final bool obscureText;
  final bool showIconObscure;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool autofocus;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.showIconObscure = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.autofocus = false,
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
    _updateObscureIcon();
  }

  void _updateObscureIcon() {
    _iconObscure = _obscureText
        ? const Icon(Icons.visibility_off_outlined)
        : const Icon(Icons.visibility_outlined);
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _updateObscureIcon();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: widget.validator,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: widget.icon,
        suffixIcon: widget.showIconObscure
            ? IconButton(
                onPressed: _toggleObscureText,
                icon: _iconObscure,
              )
            : null,
        filled: widget.fillColor != null,
        fillColor: widget.fillColor,
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: widget.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
      ),
    );
  }
}