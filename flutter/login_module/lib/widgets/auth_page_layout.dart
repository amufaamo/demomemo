// lib/widgets/auth_page_layout.dart
import 'package:flutter/material.dart';

/// 認証画面（ログイン、新規登録、パスワードリセットなど）用の共通レイアウトウィジェット。
///
/// 画面幅に応じて、モバイル向け（縦長、中央配置）と
/// ワイドスクリーン向け（中央配置、Cardで囲む）のレイアウトを切り替えます。
class AuthPageLayout extends StatelessWidget {
  /// このレイアウトの中に表示するメインのコンテンツ（フォームなど）。
  final Widget child;

  /// フォーム部分の最大幅（ワイドスクリーン時）。null の場合は制限なし。
  final double? maxFormWidth;

  /// Card の標高（ワイドスクリーン時）。
  final double cardElevation;

  /// Card の外側のマージン（ワイドスクリーン時）。
  final EdgeInsetsGeometry cardMargin;

  /// Card の内側のパディング（ワイドスクリーン時）。
  final EdgeInsetsGeometry cardPadding;

  /// モバイルレイアウト時のパディング。
  final EdgeInsetsGeometry mobilePadding;

  const AuthPageLayout({
    super.key,
    required this.child,
    this.maxFormWidth = 500, // デフォルトの最大幅
    this.cardElevation = 8.0,
    this.cardMargin = const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
    this.cardPadding = const EdgeInsets.all(40.0),
    this.mobilePadding = const EdgeInsets.all(32.0),
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder を使って利用可能な描画領域の制約を取得
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面幅が 600 ピクセル未満の場合はモバイルレイアウト
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout(context);
        } else {
          // それ以外の場合はワイドレイアウト
          return _buildWideLayout(context);
        }
      },
    );
  }

  // --- モバイルレイアウト (縦長、中央、スクロール可能) ---
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      // SingleChildScrollView で、画面に収まらない場合にスクロールできるようにする
      child: SingleChildScrollView(
        padding: mobilePadding, // 周囲にパディングを設定
        child: child, // 受け取ったコンテンツを表示
      ),
    );
  }

  // --- ワイドレイアウト (タブレット/Web向け、中央、Card表示、スクロール可能) ---
  Widget _buildWideLayout(BuildContext context) {
    return Center(
      // SingleChildScrollView で、画面に収まらない場合にスクロールできるようにする
      child: SingleChildScrollView(
        // ConstrainedBox でフォーム部分の最大幅を制限する
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxFormWidth ?? double.infinity),
          // Card ウィジェットで見栄えを良くする
          child: Card(
            elevation: cardElevation, // Card の影
            margin: cardMargin, // Card の外側の余白
            child: Padding(
              padding: cardPadding, // Card の内側の余白
              child: child, // 受け取ったコンテンツを表示
            ),
          ),
        ),
      ),
    );
  }
}