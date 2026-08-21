import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController _controller;
  final String textLabel;


  const PasswordTextField({
    super.key,
    required this._controller,
    this.textLabel = 'Senha'
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget._controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.textLabel,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}