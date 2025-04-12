// lib/utils/snackbar_utils.dart
import 'package:flutter/material.dart';

class SnackbarUtils {

  // プライベートな共通メソッド
  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    // context が有効かどうかのチェックを追加 (非同期処理後に表示する場合など)
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    // 表示中のスナックバーがあれば隠す (連続表示を防ぐ)
    messenger.hideCurrentSnackBar();
    // 新しいスナックバーを表示
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // 少し浮いたスタイルに (任意)
        // duration: const Duration(seconds: 3), // 表示時間を変更する場合 (任意)
      ),
    );
  }

  /// エラーメッセージ用の Snackbar を表示します。
  static void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.redAccent); // デフォルトのエラー色
  }

  /// 成功メッセージ用の Snackbar を表示します。
  static void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green); // デフォルトの成功色
  }

  // 以前の showError メソッドは削除
}