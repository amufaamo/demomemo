// lib/pages/password_reset_page.dart
import 'package:flutter/material.dart';
// ★ AuthService と SnackbarUtils をインポート
import '../services/auth_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/logo_widget.dart'; // LogoWidget をインポート
import '../widgets/email_form_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/loading_indicator.dart';

class PasswordResetPage extends StatefulWidget {
  final AuthService authService; // ★ AuthService をコンストラクタで受け取る
  final VoidCallback onPasswordResetSent; // ★ メール送信成功時のコールバック
  final String? logoAssetPath; // ★ ロゴのアセットパス (オプション)

  const PasswordResetPage({
    super.key,
    required this.authService,
    required this.onPasswordResetSent,
    this.logoAssetPath, // ★ ロゴのアセットパスを受け取る
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // AuthService のエラーメッセージを監視
    widget.authService.errorMessage.addListener(_handleAuthError);
  }

  @override
  void dispose() {
    // リスナーを解除
    widget.authService.errorMessage.removeListener(_handleAuthError);
    _emailController.dispose();
    super.dispose();
  }

  // --- エラーハンドリング ---
  void _handleAuthError() {
    final message = widget.authService.errorMessage.value;
    // user-not-found はここではエラーとして扱わない場合があるため、
    // AuthService側でハンドリングされている想定。
    // ここではそれ以外のエラー、またはAuthServiceでエラーと判断されたものを表示。
    if (message != null && mounted) { // mounted チェックを追加
      SnackbarUtils.showErrorSnackBar(context, message);
      widget.authService.errorMessage.value = null; // クリア
    }
  }

  // --- パスワードリセットメール送信処理 ---
  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus(); // キーボードを閉じる
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();

      // AuthService のメソッドを呼び出す
      final success = await widget.authService.sendPasswordResetEmail(email);

      // メール送信処理が成功（または user-not-found 等で UI 上成功扱い）した場合
      if (mounted && success) {
         // SnackbarUtils.showSuccessSnackBar(context, 'パスワードリセット用のメールを送信しました。\nメールボックスをご確認ください。'); // 不要なら削除
         widget.onPasswordResetSent(); // ★ 成功コールバックを呼び出す
      }
      // エラー発生時は _handleAuthError で Snackbar が表示される
    } else {
      // フォームのバリデーションエラーの場合
      if (mounted) {
        SnackbarUtils.showErrorSnackBar(context, 'メールアドレスを確認してください');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワードリセット'), // AppBar があった方が親切
      ),
      body: AuthPageLayout(
        // AuthService の isLoading 状態を監視
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.authService.isLoading,
          builder: (context, isLoading, _) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- ロゴ ---
                  if (widget.logoAssetPath != null) // ★ logoAssetPath があれば表示
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: LogoWidget(logoAssetPath: widget.logoAssetPath!),
                    )
                  else // ★ なければ SizedBox でスペースだけ確保 (任意)
                    const SizedBox(height: 40.0),

                  // --- ページタイトルと説明 ---
                  Text(
                    'Password Reset',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Enter your registered email address.\nWe'll send you a link to reset your password.",
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 30.0),

                  // --- メールアドレス入力 ---
                  EmailFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: isLoading ? null : (_) => _sendResetEmail(),
                  ),
                  const SizedBox(height: 24.0),

                  // --- ローディング表示 または 送信ボタン ---
                  if (isLoading)
                    const LoadingIndicator()
                  else
                    SubmitButton(
                      text: 'リセットメールを送信',
                      onPressed: _sendResetEmail,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}