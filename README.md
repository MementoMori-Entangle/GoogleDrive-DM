# CAFirstTest

Google Drive と連携したファイル管理アプリ（Flutter製）

## セットアップ

```bash
git clone <このプロジェクト>
cd CAFirstTest
flutter pub get
flutter run
```

## 依存パッケージ

- google_sign_in
- googleapis
- provider
- shared_preferences

## 構成例

- `lib/screens/` ... 各画面
- `lib/services/` ... 認証/API連携/ディレクトリ管理
- `lib/models/` ... データモデル
- `lib/repositories/` ... データ永続化
- `lib/widgets/` ... 共通UI部品
