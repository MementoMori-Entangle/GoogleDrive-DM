// アプリ全体で使用する定数・設定値を集約

class AppConfig {
  // アプリ名
  static const String appName = 'Google Drive Directory Manager';
  static const String appTitleMain = 'Google Drive';
  static const String appTitleSub = 'Directory Manager';

  // ウィンドウサイズ（Windowsデスクトップ用）
  static const double windowWidth = 540;
  static const double windowHeight = 960;
  static const double windowMinWidth = 540;
  static const double windowMinHeight = 960;
  static const double windowMaxWidth = 1280;
  static const double windowMaxHeight = 960;
  static const double windowLeft = 100;
  static const double windowTop = 100;

  // Linuxデスクトップ用ウィンドウサイズ
  static const double windowMinWidthLinux = 540;
  static const double windowMinHeightLinux = 960;
  static const double windowMaxWidthLinux = 1280;
  static const double windowMaxHeightLinux = 960;
  static const double windowLeftLinux = 100;
  static const double windowTopLinux = 100;
  static const double windowWidthLinux = 540;
  static const double windowHeightLinux = 960;

  // Google OAuth2.0 クライアントID（Web/Windows/Android/iOSで分ける場合はここで管理）
  static const String googleClientIdWeb =
      '609658788523-m1j97v6u68fm99efheegngk676m9lhr3.apps.googleusercontent.com';
  static const String googleClientIdWindows =
      '36978407151-o8tupvsfdhmlrsm1su0uifj6632euv90.apps.googleusercontent.com';
  static const String googleClientIdLinux =
      '36978407151-rs6opmecs27ht6e8k7jk4kht3l981ahp.apps.googleusercontent.com';
  // Android/iOS用は必要に応じて追加

  // Google OAuth2.0 クライアントシークレット（Windows用）
  // 本番運用時は環境変数から取得する。なければ空文字列。
  static String get googleClientSecretWindows =>
      const String.fromEnvironment('GOOGLE_CLIENT_SECRET_WINDOWS',
          defaultValue: '');
  static String get googleClientSecretLinux =>
      const String.fromEnvironment('GOOGLE_CLIENT_SECRET_LINUX',
          defaultValue: '');

  // Google OAuth2.0 スコープ
  static const List<String> googleScopes = [
    'email',
    'https://www.googleapis.com/auth/drive.readonly',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  // Windows用OAuth2.0リダイレクトポート
  static const int windowsRedirectPort = 8080;
  static String get windowsRedirectUri =>
      'http://localhost:$windowsRedirectPort';
  static const int linuxRedirectPort = 8081;
  static String get linuxRedirectUri => 'http://localhost:$linuxRedirectPort';

  // その他の設定値（必要に応じて追加）
  static const Duration serverCloseDelay = Duration(milliseconds: 100);

  /// 履歴・ディレクトリ等の最大登録件数
  static const int maxHistoryEntries = 100;

  /// ディレクトリ最大登録件数
  static const int maxDirectoryEntries = 100;
}
