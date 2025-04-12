// lib/widgets/submit_button.dart
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // null の場合は非活性
  final double verticalPadding;
  final double fontSize;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.verticalPadding = 16.0,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        // テーマカラーを適用する場合
        backgroundColor: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.12), // 非活性時の色
        foregroundColor: onPressed != null
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.38), // 非活性時の文字色
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }
}