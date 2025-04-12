// login_module/lib/pages/login_page.dart
import 'package:flutter/material.dart';
// ★ AuthService と SnackbarUtils をインポート
import '../services/auth_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/email_form_field.dart';
import '../widgets/password_form_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/logo_widget.dart'; // LogoWidget をインポート

class LoginPage extends StatefulWidget {
  final AuthService authService; // ★ AuthService をコンストラクタで必須にする
  final VoidCallback onLoginSuccess;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onPasswordResetTap;
  final String? logoAssetPath; // ★ ロゴウィジェットではなくアセットパスを受け取る

  const LoginPage({
    super.key,
    required this.authService, // ★ 必須に変更
    required this.onLoginSuccess,
    this.onRegisterTap,
    this.onPasswordResetTap,
    this.logoAssetPath, // ★ ロゴのアセットパスを受け取る
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode(); // パスワード用フォーカス

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
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // --- エラーハンドリング ---
  void _handleAuthError() {
    final message = widget.authService.errorMessage.value;
    if (message != null && mounted) {
      // mounted チェックを追加
      SnackbarUtils.showErrorSnackBar(context, message);
      widget.authService.errorMessage.value = null; // クリア
    }
  }

  // --- ログイン処理 ---
  Future<void> _login() async {
    FocusScope.of(context).unfocus(); // キーボードを閉じる

    if (_formKey.currentState?.validate() ?? false) {
      // AuthService を使ってログイン試行
      // ★★★ ここは修正済みのはず: email と password を名前付き引数で渡す ★★★
      final userCredential = await widget.authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ログイン成功時 (エラーメッセージがnullで、userCredentialが取得できた場合)
      if (mounted &&
          widget.authService.errorMessage.value == null &&
          userCredential != null) {
        widget.onLoginSuccess(); // 成功コールバックを呼ぶ
      }
      // エラー発生時は _handleAuthError で Snackbar が表示される
    } else {
      // フォームのバリデーションエラーの場合
      if (mounted) {
        SnackbarUtils.showErrorSnackBar(context, '入力内容を確認してください');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AuthPageLayout を使用
      body: AuthPageLayout(
        // AuthService の isLoading 状態を監視
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.authService.isLoading,
          builder: (context, isLoading, _) {
            return Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center, // AuthPageLayoutが中央寄せするので不要かも
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

                  // --- ページタイトル ---
                  Text(
                    'Login', // タイトルを追加
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 30.0), // タイトル下のスペース
                  // --- メールアドレス入力 ---
                  EmailFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next, // 次のフィールドへ
                    onFieldSubmitted:
                        (_) => FocusScope.of(
                          context,
                        ).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 16.0),

                  // --- パスワード入力 ---
                  PasswordFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode, // フォーカスノードを設定
                    labelText: 'パスワード',
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done, // 完了アクション
                    onFieldSubmitted:
                        isLoading ? null : (_) => _login(), // 送信アクション
                  ),
                  const SizedBox(height: 8.0), // パスワード忘れリンクとの間隔を少し詰める
                  // --- パスワードリセットボタン ---
                  if (widget.onPasswordResetTap != null)
                    Align(
                      // 右寄せにする
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : widget.onPasswordResetTap,
                        child: const Text('パスワードを忘れましたか？'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ), // パディング調整
                      ),
                    ),
                  const SizedBox(height: 16.0), // ログインボタンとの間隔
                  // --- ローディング表示 または ログインボタン ---
                  if (isLoading)
                    const LoadingIndicator()
                  else
                    SubmitButton(onPressed: _login, text: 'ログイン'),
                  const SizedBox(height: 24.0), // 新規登録ボタンとの間隔
                  // --- 新規登録ボタン ---
                  if (widget.onRegisterTap != null)
                    TextButton(
                      onPressed: isLoading ? null : widget.onRegisterTap,
                      child: const Text('アカウントをお持ちでないですか？ 新規登録'),
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