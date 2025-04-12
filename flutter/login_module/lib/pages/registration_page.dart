// lib/pages/registration_page.dart
import 'package:flutter/material.dart';
// ★ AuthService と SnackbarUtils をインポート
import '../services/auth_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/logo_widget.dart'; // LogoWidget をインポート
import '../widgets/email_form_field.dart';
import '../widgets/password_form_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/loading_indicator.dart';

class RegistrationPage extends StatefulWidget {
  final AuthService authService; // ★ AuthService をコンストラクタで受け取る
  final VoidCallback onRegistrationSuccess; // ★ 登録成功時のコールバック
  final String? logoAssetPath; // ★ ロゴのアセットパス (オプション)

  const RegistrationPage({
    super.key,
    required this.authService,
    required this.onRegistrationSuccess,
    this.logoAssetPath, // ★ ロゴのアセットパスを受け取る
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

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
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // --- エラーハンドリング ---
  void _handleAuthError() {
    final message = widget.authService.errorMessage.value;
    if (message != null && mounted) { // mounted チェックを追加
      SnackbarUtils.showErrorSnackBar(context, message);
      // エラーメッセージをクリアして、再度表示されないようにする
      widget.authService.errorMessage.value = null;
    }
  }

  // --- 新規登録処理 ---
  Future<void> _register() async {
    FocusScope.of(context).unfocus(); // キーボードを閉じる
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // AuthService のメソッドを呼び出す
      // ★★★ ここを修正: createUserWithEmail を名前付き引数で呼び出す ★★★
      final userCredential = await widget.authService.createUserWithEmail(
        email: email,       // ★ 名前付き引数 email
        password: password,    // ★ 名前付き引数 password
      );

      // 登録成功時 (エラーメッセージがnullで、userCredentialが取得できた場合)
      if (mounted && widget.authService.errorMessage.value == null && userCredential != null) {
        widget.onRegistrationSuccess(); // ★ 成功コールバックを呼び出す
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
      appBar: AppBar(
        title: const Text('新規アカウント登録'),
      ),
      body: AuthPageLayout(
        // AuthService の isLoading 状態を監視
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.authService.isLoading,
          builder: (context, isLoading, _) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Card 内で適切な高さになるように
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
                    'Create Account',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Enter your email address and password.",
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 30.0),

                  // --- メールアドレス入力 ---
                  EmailFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 16.0),

                  // --- パスワード入力 ---
                  PasswordFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    enabled: !isLoading,
                    labelText: 'パスワード (6文字以上)', // 最低文字数を明記
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'パスワードを入力してください'; // 基本的な必須チェックも追加
                      }
                      if (value.length < 6) {
                        return '6文字以上で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // --- 確認用パスワード入力 ---
                  PasswordFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    enabled: !isLoading,
                    labelText: 'パスワード（確認用）',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: isLoading ? null : (_) => _register(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '確認用パスワードを入力してください';
                      }
                      if (value != _passwordController.text) {
                        return 'パスワードが一致しません';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0), // ボタンとの間隔

                  // --- ローディング表示 または 登録ボタン ---
                  // isLoading が true の場合にインジケーターを表示
                  if (isLoading)
                    const LoadingIndicator()
                  else // ローディング中でない場合に登録ボタンを表示
                    SubmitButton(
                      text: '登録する',
                      onPressed: _register, // isLoading はチェック済みなので常に有効
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