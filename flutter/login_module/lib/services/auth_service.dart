// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // ValueNotifier のため

/// Firebase Authentication の操作をラップし、状態を提供するサービスクラス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 状態Notifier ---
  /// ローディング状態（true: 処理中, false: 待機中）
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// 直近で発生したエラーメッセージ（エラーがない場合は null）
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  // --- 認証状態の監視 ---
  /// ユーザーの認証状態が変わるたびに通知されるストリーム
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 現在ログインしているユーザー（ログインしていない場合は null）
  User? get currentUser => _auth.currentUser;

  // --- 主要な認証メソッド ---

  /// メールアドレスとパスワードでログイン
  // ★★★ 引数を名前付き引数 {required String email, required String password} に変更 ★★★
  Future<UserCredential?> signInWithEmail(
      {required String email, required String password}) async {
    // _callAuthMethod に渡す関数内でも email: と password: を使う
    return await _callAuthMethod(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  /// メールアドレスとパスワードで新規ユーザー登録
  // ★★★ 引数を名前付き引数 {required String email, required String password} に変更 ★★★
  Future<UserCredential?> createUserWithEmail(
      {required String email, required String password}) async {
    // _callAuthMethod に渡す関数内でも email: と password: を使う
    return await _callAuthMethod(
      () => _auth.createUserWithEmailAndPassword(email: email, password: password),
    );
  }

  /// パスワードリセットメールを送信
  // こちらは元々引数が一つなのでそのままでOK
  Future<bool> sendPasswordResetEmail(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    bool success = false;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      success = true; // エラーが出なければ成功とみなす
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Password reset email sent request processed (user-not-found).');
        success = true;
      } else {
        errorMessage.value = _mapAuthErrorCode(e.code);
        success = false;
      }
    } catch (e) {
      print('sendPasswordResetEmail error: $e');
      errorMessage.value = '予期せぬエラーが発生しました。';
      success = false;
    } finally {
      isLoading.value = false;
    }
    return success;
  }

  /// ログアウト
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // --- ヘルパーメソッド ---

  /// FirebaseAuth のメソッドを呼び出し、ローディング状態とエラーを管理する共通処理
  Future<T?> _callAuthMethod<T>(Future<T> Function() method) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await method();
      return result;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthErrorCode(e.code);
      print('FirebaseAuthException in _callAuthMethod: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value = '予期せぬエラーが発生しました。';
      print('Exception in _callAuthMethod: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// FirebaseAuthException のエラーコードを日本語メッセージに変換
  String _mapAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return '指定されたメールアドレスのユーザーは見つかりません。';
      case 'wrong-password':
        return 'パスワードが間違っています。';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません。';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています。';
      case 'weak-password':
        return 'パスワードが弱すぎます。6文字以上で設定してください。';
      case 'too-many-requests':
        return '試行回数が上限を超えました。しばらくしてからもう一度お試しください。';
      case 'network-request-failed':
        return 'ネットワーク接続に問題があります。接続を確認してください。';
      case 'invalid-credential':
        return 'メールアドレスまたはパスワードが正しくありません。';
      default:
        print('Unhandled FirebaseAuthException code: $code');
        return '認証中に不明なエラーが発生しました。($code)';
    }
  }

  /// ValueNotifier を破棄するためのメソッド (Stateのdisposeで呼ぶ)
  void disposeNotifiers() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}