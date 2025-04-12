// lib/widgets/email_form_field.dart
import 'package:flutter/material.dart';

/// メールアドレス入力に特化した TextFormField ウィジェット
class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?)? validator; // 外部から追加のバリデーションを渡せるように
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const EmailFormField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(
        labelText: 'メールアドレス',
        hintText: 'your@email.com', // プレースホルダー
        border: OutlineInputBorder(), // 枠線
        prefixIcon: Icon(Icons.email), // 前置アイコン
      ),
      keyboardType: TextInputType.emailAddress, // メールアドレス用キーボード
      autocorrect: false, // 自動修正オフ
      textInputAction: textInputAction, // キーボードのアクションボタン
      onFieldSubmitted: onFieldSubmitted, // 送信時の動作
      validator: (value) {
        // 基本的な必須チェック
        if (value == null || value.isEmpty) {
          return 'メールアドレスを入力してください';
        }
        // 簡単な形式チェック (より厳密にする場合は正規表現などを使用)
        final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegExp.hasMatch(value)) {
          return '有効なメールアドレスを入力してください';
        }
        // 外部から渡された追加のバリデーションを実行
        if (validator != null) {
          return validator!(value);
        }
        return null; // 問題なければ null を返す
      },
      autovalidateMode: AutovalidateMode.onUserInteraction, // 入力中にリアルタイムで検証
      enabled: enabled, // 有効/無効状態
    );
  }
}