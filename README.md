# GoogleDriveDirectoryManager

Google Drive と連携したディレクトリ管理アプリ（Flutter製）

GitHub copilot agent(GPT-4.1)で実装してみました。  
使用したDart言語やフレームワークのFlutterは初めて使用しました。(知識ゼロ)

--エージェントに初回に投げたコンテキスト  
初期要件定義  
GoogleDriveディレクトリ管理アプリケーション

グーグルドライブにアクセスするためには認証が必要となるため、  
事前にログイン画面でグーグルドライブAPIのAuth2.0に基づく情報を入力して  
認証に成功したら、ログインも成功とし、アプリケーションの以下メイン画面へ遷移する。

グーグルドライブの指定ディレクトリに存在する  
ファイルの数と容量を取得して画面表示するアプリケーション  
指定ディレクトリはグーグルドライブのディレクトリIDを  
指定することで任意に切り替えたい。  
そのため、グーグルドライブのディレクトリIDを登録・修正・削除できる画面と  
登録されているディレクトリIDを一覧で表示する画面も別途必要です。

言語は「Dart」を使用  
フレームワークは「flutter」を使用  
対応OSは「Android」「iOS」「Web」「Windows」の4種類を希望ですが、  
まずはAndroidをエミュレータでテストしたいです。  
--ここまで

事前にJDK24、JDK17(keytoolの問題対応)、AndriodStudio、  
Git、VSC(拡張機能含む)、Dart、Flutterの環境は整えられていること  

## これまでの作業の流れ

1. プロジェクト雛型ディレクトリ・ファイルを自動生成(エージェント出力)
2. 必要な依存パッケージ（google_sign_in, googleapis, provider, shared_preferences）を [`pubspec.yaml`](pubspec.yaml) に追加
3. Google認証・Google Drive API連携のためのサービスクラスを作成
4. ディレクトリ・ファイル情報のデータモデルを [`lib/models/`](lib/models/) に実装
5. ディレクトリ履歴の永続化用リポジトリ [`lib/repositories/directory_history_repository.dart`](lib/repositories/directory_history_repository.dart) を作成
6. 画面（ログイン、ディレクトリ一覧、履歴など）を [`lib/screens/`](lib/screens/) に実装
7. アプリ全体のエントリーポイント・ルーティングを [`lib/app.dart`](lib/app.dart) で構築
8. 動作確認・デバッグ・コミット

## セットアップ

```bash  
git clone <このプロジェクト>  
cd GoogleDrive-DM  
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

GoogleDrive-DM\android\app\google-services.jsonは念のため管理対象外としました。  
console.firebase.google.comで環境に合わせて作成する必要があります。(SHA1絡み)

初期要件定義の機能をエミュレータで確認した後、  
あれもこれも欲しいと次々と機能をエージェントに要求して  
色々機能を拡張しました。

ログイン画面(グーグルアカウント使用 AOuth2.0)  
|  
GoogleDriveDirectoryManager画面(メイン)  
ヘッダメニュー  
|__アプリ終了(アプリ終了時にグーグルアカウントから強制ログアウト)  
|__ログアウト  
|__ディレクトリ履歴画面  
|__ディレクトリ一覧画面  
|  |__登録(IDはログインアカウントのドライブディレクトリIDを指定)  
|  |__修正(ディレクトリ名はアプリ側で独自管理 グーグルドライブには影響を与えません)  
|  |__削除(アプリ側の情報を削除するのでグーグルドライブには影響を与えません)  
|__ログイン情報(ユーザー名とメールアドレス)  
| |__指定ディレクトリ選択ボックス  
| |__ファイル数表示  
| |__総容量表示  
|__グーグルドライブ指定ディレクトリ全総ファイル数表示  
|__グーグルドライブ使用容量/総容量表示

画面1
<img width="343" alt="001_アプリInfo" src="https://github.com/user-attachments/assets/cdf43e2d-999f-4020-8ed0-6202e591f558" />
画面2
<img width="343" alt="002_ログイン(起動)画面" src="https://github.com/user-attachments/assets/a3122be1-a1fe-4e62-8dcd-169d22fa67e1" />

画面3
<img width="343" alt="003_アカウント選択画面" src="https://github.com/user-attachments/assets/03947eb0-fbb6-4df7-8dd9-4480c3a0a237" />
画面4
<img width="343" alt="004_メイン画面" src="https://github.com/user-attachments/assets/8a015c16-58a1-4d38-8ff5-ddd54627697e" />

画面5
<img width="343" alt="005_メイン(ディレクトリ選択)画面" src="https://github.com/user-attachments/assets/d7a9b7f5-a9cc-42c2-9331-5f2d1bceba2b" />
画面6
<img width="343" alt="006_メイン(ディレクトリ選択後)画面" src="https://github.com/user-attachments/assets/a573b4ac-17f8-47ee-9307-563f16b75d7c" />

画面7
<img width="343" alt="007_ディレクトリ一覧画面" src="https://github.com/user-attachments/assets/1d35b7e7-634e-4c1f-9873-fa29c75685ca" />
画面8
<img width="343" alt="008_ディレクトリ(名)編集(初期)画面" src="https://github.com/user-attachments/assets/74a0c9c3-a0b8-4f2d-aaf7-9cfd1aeac91f" />

画面9
<img width="343" alt="009_ディレクトリ(名)編集(入力)画面" src="https://github.com/user-attachments/assets/a6b498cb-620f-476e-8aec-c70d5c1c6c56" />
画面10
<img width="343" alt="010_ディレクトリ一覧(修正後)画面" src="https://github.com/user-attachments/assets/83cae559-a128-48ea-bd5b-218d8e45cf71" />

画面11
<img width="343" alt="011_メイン(ディレクトリ名修正後)画面" src="https://github.com/user-attachments/assets/93626de3-da7b-4fc6-98a7-010949e31983" />  
画面12 (画面8で削除ボタン押下)
<img width="343" alt="012_ディレクトリ一覧(ディレクトリ削除後)画面" src="https://github.com/user-attachments/assets/9fdf6934-d6d8-4bc9-adb8-75545eb85a46" />

画面13
<img width="343" alt="013_メイン(ディレクトリ削除後)画面" src="https://github.com/user-attachments/assets/d1dd43c1-1a84-44b0-97e1-98a7e793775d" />
画面14
<img width="343" alt="014_ディレクトリID登録(初期)画面" src="https://github.com/user-attachments/assets/f25870b3-f88c-4799-ad2f-99c4527383d9" />

画面15
<img width="343" alt="015_ディレクトリID登録(入力後)画面" src="https://github.com/user-attachments/assets/85f601d9-39a8-428f-8227-2caba7ffd83a" />
画面16
<img width="343" alt="016_ディレクトリ一覧(登録後)画面" src="https://github.com/user-attachments/assets/a5d754e2-05f3-4f7a-977e-81254fa5a420" />

画面17
<img width="343" alt="017_メイン(ディレクトリ登録後)画面" src="https://github.com/user-attachments/assets/955e37be-f263-472a-94f6-cb95bd764ef7" />
画面18
<img width="343" alt="018_ディレクトリ操作履歴画面" src="https://github.com/user-attachments/assets/5c763ef1-5dd7-45fe-968e-7f335b2bfec6" />

コードは全てエージェントが書いてます。  

私がしたことは、エージェントが関与できないGitHubに関する設定  
console.cloud.google.comでOAUTHの設定  
console.firebase.google.comでAndroidのパッケージ設定(SHA1)  
公開前テスト状態なので、複数アカウントでテストするため、テスターアカウントの設定

必要なソフトウェアのインストールは含まない物としても  
簡単な要件定義から実装、テスト(は手動)までおおよそ8時間で完了しました。  
セキュリティについて以下懸念点はあるが、扱う情報的には大きな問題にはならない。

以下エージェント診断  
SharedPreferencesは暗号化されていないため、端末のroot化や物理的アクセスがあれば  
データを読み取られる可能性があります。  
機密性が高い情報（パスワードやトークンなど）は保存しないでください。  
Googleアカウントの認証・認可はGoogleSignIn/GoogleAPIに依存しており、  
これ自体は安全ですが、APIキーやクライアントシークレットなどは  
アプリ内にハードコーディングしないようにしてください。  
外部サーバーやクラウドへのデータ送信は行っていないため、  
ネットワーク経由の情報漏洩リスクはありません。  
端末のユーザー切り替えやアプリのアンインストール時には、  
SharedPreferencesのデータが残る場合があります。

私が作業した部分で時間を取ったのは、環境作りだと思います。  
JDK24でSHA1が作成できなくて、JDK17にたどりつくのに30分くらいかかりました。  
グーグルクラウドでの設定作業が慣れていなくて30分くらいかかりました。(知ってれば5分で終わる)  
AndroidエミュレータのDevice manager設定でgoogle play service(開発者サービス)がインストールされている  
イメージかつ、アカウントでストアにアクセスしてアップデートしないと、  
テストしたいアプリがクラッシュするということを知らなくて  
解決にたどりつけるまで1時間くらいかかりました。  
これで合計2時間くらいです。  
実質エージェントに指示を出してたのは6時間くらいになります。  
初めてエージェントを使用して作成した時間にしてはまぁまぁなのではないでしょうか。  
(エージェントがなかったら、グーグル先生で分からないことを検索して試行錯誤してどれほどかかっていただろう)  
あとはソースコードレビューして知識吸収したり、自動テストの実装と手動テスト追加を行っていく予定です。

2日目微調整していたら、エージェントが何らかのセッション制限や環境要因でツールが動作していません。  
と言い出して、あえなく手動修正することに・・・  時間がたっても治らなかったので、  
最新リポジトリから環境作り直ししたらエージェント使えるようになりました。(原因不明)

# Web版追加
第2弾もGitHub copilot agent(GPT-4.1)で実装してみました。  
ただし、エージェントが動かないため「ask」でVibe codingで試しました。  
結果、完成率99％で失敗、ディレクトリID登録から一覧に戻り、メイン画面に戻るときに、  
必ずトークン消失でGoogleDriveにアクセスできなくなる問題が発生しました。  
askとwebで調べつくしても原因が判明しなく、firebaseの設定なのか  
プログラムが悪いのか切り分けも難しかったので、一旦仕切り直しにしました。(4時間くらい)  
次にリポジトリから最新を取り直して・・・ここでエージェントが復活したので、  
次はエージェントに一からfirebaseを使用して実装を依頼しました。  
結果、完成率10％くらいでした。まさかのログイン認証処理が突破できませんでした。(2時間くらい)  
一度firebaseはあきらめて、シンプルにAndroid版と同じGoogle認証  
（google_sign_in）で処理することにしました。  
結果、さっくと完成しました。(30分くらい)  
flutter+firebaseの実装は(GPT-4.1)エージェントでは学習データが少ない?  
(上位モデルのプレミアムリクエストで処理するか悩んだけど、  
MMGのデータサイエンスにかかわることに使いたいので我慢)

私がやったことはエージェントに指示を出して、  
OAuth2.0認証用にconsole.cloud.google.comのOAuth 2.0 クライアント IDを作成して  
クライアントIDをエージェントに提示し、動作確認⇔指示の繰り返しでした。

以下エージェントが修正した概要(コンテキストで生成)

Web版対応で作成・修正した主なファイルと対応内容

index.html  
<meta name="viewport" ...> を追加し、スマートフォンサイズでの表示に最適化  
<meta name="google-signin-client_id" ...> を追加し、Google認証（google_sign_in）をWebで有効化

main_screen.dart  
Web版では「アプリ終了」ボタンを非表示にするようkIsWeb判定を追加  
Web用のダミーデータ（ファイル数・容量など）を返す実装を追加  
レイアウトやUIがWeb/スマホでも崩れないよう調整

directory_service.dart  
ユーザーIDの扱いをWeb/Android/iOSで共通化し、Webでもディレクトリ情報が永続化されるよう修正

directory_repository.dart  
（内部実装）Webでshared_preferencesのsetStringList/getStringListが動作しない場合に備え、  
setString/  getString＋jsonエンコード/デコード方式で保存するよう修正

login_screen.dart  
Google認証（google_sign_in）によるログイン処理をWebでも動作するよう整理

# Windows版追加
第3弾もGitHub copilot agent(GPT-4.1)で実装してみました。  
今回はAndriod版やweb版と違いOAuth2.0認証周りを別途独自実装する必要があり、  
この切り分け作業でエージェントが主にweb版に大きく影響を与えることになりました。  
Windows版で使用する機能(パッケージ)をimportするだけでweb版がクラッシュすることになりました。  
ネイティブの部分はしっかりエージェントに都度支持を出さないと、  
他環境に影響を与える実装をすることがあるので要注意です。  
今回のWindows版対応は約8時間かかりました。  
一番時間がかかったのは、シークレットキーの扱いです。  
実装時にエージェントはWindowsアプリではクライアントキーだけでよくて、  
シークレットキーはなくてもいいよとかたくなに譲らなくて、すっかり信じ込んでしまったため、  
2時間くらいなんで認証されないんだろうとconsole.cloud.google.comの  
OAuthの設定を変えたりして、動作確認をしていました。  
公式のドキュメントを読ませて学習させても、シークレットキーはなくてもいいよとなるし・・・  
console.cloud.google.com側の設定がいけないのかFlutterのコードがいけないのかわからなくなったので、  
Windowsアプリということもあり、C#で認証アプリ作ってどうなるか試してみました。  
結果、シークレットキーは必須でした。  
Exceptionコピペしてエージェントに渡したら、2024年まではなんちゃらといい、  
仕様変わったんですかね?みたい発言をしてきました。(慢心ダメ絶対)  

console.cloud.google.com追加設定は  
OAuth 2.0 クライアント IDを種類デスクトップで作成  
データアクセスにWindows版で使用する../auth/userinfo.email、openid、  
.../auth/userinfo.profileの3種を新たに追加  
(Andriod版、web版でも使う、.../auth/drive.readonlyはそのまま)

Windows版をビルド(テスト)するときは環境変数にシークレットキーを引数で渡す必要があるので注意  
flutter run -d windows --dart-define=GOOGLE_CLIENT_SECRET_WINDOWS=シークレットキー  
flutter build windows --dart-define=GOOGLE_CLIENT_SECRET_WINDOWS=シークレットキー

# Linux版追加
第4弾もGitHub copilot agent(GPT-4.1)で実装してみました。  
今回はWindows版とほぼ変わらない実装の流れでした。  
問題は素Windows環境ではテストができないことでした。  
まず、WSLにubuntu入れてマウントしてテストしようとしましたが、  
OpenGLの問題でWindows側のXサーバー(VcXsrv)経由で画面表示しようとすると  
クラッシュ(OpenGL2.0以降が必須)してしまいました。  
問題はWindows10のWSLはOpenGL1.4からアップグレードすることが色々な問題から難しいということもあり、  
Windows10でテストしようとすると、VM環境で行う必要があります。  
というこで、買収後にフリーとなったVMware Workstationでubuntu入れてマウントしてテストしようとしました。  
OpenGLのバージョンは4.3と最新になりましたが、今度はシンボリックリンクの問題が発生、  
Windowsへシンボリックリンクはれない&VSCのworkspaceでLinux側でflutter pub getしたことにより、  
環境面の違いから問題が400件以上発生!!  
ということで、一度ブランチ切って、VMでFlutter環境作ってからビルドしてテストすることにします。  
この時点で実装30分、テスト環境作成に四苦八苦で7時間・・・テストは後日にします。    
(一応、Android、web、windows版に影響はないことは確認済み)  
今回初めてCopilotに「申し訳ございません。このモデルのレート制限を使い果たしました。  
a moment を待ってから再試行するか、別のモデルに切り替えてください。」といわれました。  
月額10ドル課金はGPT4.1無制限ですと書かれていますが、実際は短時間に大量に使用すると制限がかかるようです。  
AgentモードはIDE、askモードはブラウザ(GitHub)で使い分けたほうがより多く利用できそうです。  
(IDEとブラウザは連動していないので制限も別枠?)

Linux版のテスト(バグ修正)完了  
Linuxはuserが他環境と違い、Map<String, dynamic>で返ってきていたので処理の切り分けが必要でした。  
WindowsとLinuxで交互に行っているとflutter runした時「Error: Build process failed.」になった場合は、  
flutter pub cache repair → flutter clean → flutter pub getで改善

# integrationテスト(E2E) web版追加
./chromedriver.exe --port=4444  
flutter drive --driver=test_driver/integration_test.dart --target=test/integration_test.dart -d web-server

# widgetテスト (webベース)
flutter test test/widget_test.dart

# 単体テスト (webベース)
flutter test test/test.dart  

# ガバレッジテスト
flutter test test/test.dart --coverage or flutter test test/widget_test.dart --coverage  
genhtml coverage\lcov.info -o coverage\html  
start coverage/html/index.html  
ネイティブアプリ(Windows・Linux・MacOS)に関する一部部分はガバレッジ未対応
