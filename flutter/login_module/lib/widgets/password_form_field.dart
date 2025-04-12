// lib/widgets/password_form_field.dart
import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String labelText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode; // 次のフィールドへのフォーカス移動用など
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PasswordFormField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.labelText = 'パスワード',
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: widget.enabled // enabled が false なら押せないように
              ? () => setState(() { _isObscured = !_isObscured; })
              : null,
        ),
      ),
      obscureText: _isObscured,
      enabled: widget.enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${widget.labelText}を入力してください';
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
         // 例: 最低文字数チェック
         // if (value.length < 6) {
         //    return '6文字以上で入力してください';
         // }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}