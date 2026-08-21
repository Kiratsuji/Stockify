import 'package:flutter/material.dart';

//Classes utilitarias
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
class CommonTextField extends StatefulWidget{
  final TextEditingController _controller;
  final String labelText;

  const CommonTextField({
    super.key,
    required this._controller,
    required this.labelText
  });

  @override
  State<StatefulWidget> createState() => _CommonTextFieldState();
}


//Classes de estados
class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget._controller,
      obscureText: _obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.textLabel,
        labelStyle: TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
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
class _CommonTextFieldState extends State<CommonTextField>{
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget._controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(color: Colors.white),
          border: const OutlineInputBorder()
      ),
    );
  }
}