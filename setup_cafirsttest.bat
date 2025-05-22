@echo off
REM CAFirstTest プロジェクトの雛型ディレクトリ・ファイル自動生成スクリプト

REM 開発リポジトリフォルダまで移動
cd C:\workspace\flutter\CAFirstTest

REM ディレクトリ作成
mkdir lib
mkdir lib\screens
mkdir lib\models
mkdir lib\services
mkdir lib\repositories
mkdir lib\widgets
mkdir test

REM 空ファイル作成
type NUL > lib\main.dart
type NUL > lib\app.dart
type NUL > lib\screens\login_screen.dart
type NUL > lib\screens\main_screen.dart
type NUL > lib\screens\directory_list_screen.dart
type NUL > lib\screens\directory_edit_screen.dart
type NUL > lib\models\directory.dart
type NUL > lib\models\file_info.dart
type NUL > lib\services\auth_service.dart
type NUL > lib\services\drive_service.dart
type NUL > lib\services\directory_service.dart
type NUL > lib\repositories\directory_repository.dart
type NUL > lib\widgets\custom_button.dart
type NUL > pubspec.yaml
type NUL > README.md
type NUL > test\placeholder_test.dart

echo 雛型ディレクトリ・ファイル作成完了！
pause
