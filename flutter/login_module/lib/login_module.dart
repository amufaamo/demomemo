// login_module/lib/login_module.dart
library login_module;

// --- Public API Export ---

// Pages: アプリケーションから直接利用する可能性のあるページ
export 'pages/login_page.dart';
export 'pages/registration_page.dart';
export 'pages/password_reset_page.dart';

// Services: 認証ロジックを提供するサービス
export 'services/auth_service.dart';

// Utils: アプリケーション側でも利用する可能性のあるユーティリティ
export 'utils/snackbar_utils.dart'; // ★ SnackbarUtils を export

// Widgets: (オプション) 必要であれば、個別のUI部品も export 可能
// 例: アプリ側で SubmitButton の見た目をカスタマイズしたい場合など
// export 'widgets/submit_button.dart';
// export 'widgets/email_form_field.dart';
// export 'widgets/password_form_field.dart';
// export 'widgets/logo_widget.dart';
// export 'widgets/auth_page_layout.dart';

// 注意: export する要素が増えると、パッケージの利用側での名前空間の衝突リスクが
//       わずかに上がります。必要最低限のものを export するのが一般的です。