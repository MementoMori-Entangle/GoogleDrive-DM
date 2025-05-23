# GoogleDriveDirectoryManager

Google Drive と連携したファイル管理アプリ（Flutter製）

GitHub copilot agent(GPT-4.1)でVibe codingしてみました。  
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
<img width="343" alt="018_ディレクトリ操作履歴画面" src="https://github.com/user-attachments/assets/88c594b4-201f-48af-aa42-9479d020ee2c" />

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
