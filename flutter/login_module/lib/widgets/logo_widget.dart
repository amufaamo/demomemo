// // login_module/lib/widgets/logo_widget.dart の修正例
// import 'package:flutter/material.dart';

// class LogoWidget extends StatelessWidget {
//   final String logoAssetPath; // ★ コンストラクタでパスを受け取る
//   final double? size;

//   const LogoWidget({
//     super.key,
//     required this.logoAssetPath, // ★必須パラメータにする
//     this.size,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // AppConfig.logoSize の代わりに受け取った size を使う (null ならデフォルト値)
//     final double displaySize = size ?? 100.0; // 例: デフォルトサイズを100に

//     try {
//       return Image.asset(
//         logoAssetPath, // ★ 受け取ったパスを使う
//         height: displaySize,
//         width: displaySize,
//         errorBuilder: (context, error, stackTrace) {
//           // AppConfig を使わず、受け取ったパスでエラー表示
//           print("Error loading logo: $logoAssetPath, Error: $error");
//           return Icon(Icons.error, size: displaySize); // エラーアイコン表示
//         },
//       );
//     } catch (e) {
//        print("Error loading logo asset: $logoAssetPath, Error: $e");
//        return Icon(Icons.error, size: displaySize); // エラーアイコン表示
//     }
//   }
// }

// login_module/lib/widgets/logo_widget.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer; // より詳細なログ出力のために推奨

/// アプリケーションのロゴを表示するウィジェット。
///
/// アセットパスを必須で受け取り、指定されたサイズ（またはデフォルトサイズ）で
/// ロゴ画像を表示します。画像の読み込みに失敗した場合はエラーアイコンを表示します。
/// マテリアルデザインの原則に従い、シンプルな画像表示機能を提供します。
class LogoWidget extends StatelessWidget {
  /// 表示するロゴ画像のアセットパス。
  /// 例: 'assets/images/logo.png'
  final String logoAssetPath;

  /// ロゴの表示サイズ（高さと幅）。
  /// この値が null の場合は、共通のデフォルトサイズが使用されます。
  final double? size;

  /// ロゴウィジェットのコンストラクタ。
  ///
  /// [logoAssetPath] は必須です。
  /// [size] を指定すると、そのサイズで表示されます。指定しない場合はデフォルトサイズになります。
  const LogoWidget({
    super.key,
    required this.logoAssetPath,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // ロゴの表示サイズを決定します。
    // size パラメータが指定されていればその値を、なければデフォルト値 (200.0) を使用します。
    // ★★★ 要望に合わせてデフォルトサイズを 100.0 から 200.0 (2倍) に変更 ★★★
    final double displaySize = size ?? 200.0;

    // 画像の読み込みを試みます。 try-catch で予期せぬエラーも捕捉します。
    try {
      return Image.asset(
        logoAssetPath, // 受け取ったアセットパスを使用
        height: displaySize, // 決定した表示サイズを高さに設定
        width: displaySize,  // 決定した表示サイズを幅に設定
        fit: BoxFit.contain, // 画像がコンテナに収まるように調整 (任意)

        // 画像読み込み中にエラーが発生した場合の代替表示 (Material Designのエラーアイコン使用)
        errorBuilder: (context, error, stackTrace) {
          // エラーログを出力 (開発コンソールに表示)
          // print の代わりに developer.log を使用すると、より詳細な情報を含められます。
          developer.log(
            'Failed to load logo asset: $logoAssetPath',
            name: 'LogoWidget', // ログのソースを識別しやすくする
            error: error,
            stackTrace: stackTrace,
            level: 900, // SEVERE レベル
          );
          // マテリアルデザインのエラーアイコンを表示 (サイズはロゴと同じにする)
          return Icon(
            Icons.error_outline, // より標準的なエラーアイコン
            size: displaySize,
            // テーマからエラーカラーを取得して適用
            color: Theme.of(context).colorScheme.error,
            semanticLabel: 'Logo loading failed', // スクリーンリーダー用
          );
        },
        // 画像のセマンティックラベル (アクセシビリティ対応)
        // スクリーンリーダーが画像を説明するために使用します。
        semanticLabel: 'Application Logo', // アプリケーションに応じて適切なラベルに変更してください
      );
    } catch (e, stackTrace) {
      // Image.asset の呼び出し自体で例外が発生した場合 (パスが不正など)
      developer.log(
        'Exception caught while trying to create Image.asset for: $logoAssetPath',
        name: 'LogoWidget',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // SHOUT レベル (より深刻なエラー)
      );
      // こちらもマテリアルデザインのエラーアイコンを表示
      return Icon(
        Icons.broken_image, // 画像が壊れていることを示すアイコン (任意)
        size: displaySize,
        color: Theme.of(context).colorScheme.error,
        semanticLabel: 'Logo could not be displayed', // スクリーンリーダー用
      );
    }
  }
}