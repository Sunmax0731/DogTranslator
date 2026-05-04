# DogTranslator

DogTranslator は、犬の鳴き声を録音し、感情や意図の傾向を日本語で推定表示する Windows 先行の Flutter デスクトップアプリです。公開 UI は、厳密な翻訳ではなく `犬の声 -> 人が読める解釈` に集中しています。

## 現在の製品スコープ
- Windows デスクトップアプリ
- 犬の鳴き声の録音と段階的な解析
- プロフィール、履歴、再生、ダッシュボードのローカル管理
- テーマ、入力マイク、推論モデルの設定
- 外部 Python プロセスを介した任意の Dog2vec ローカル runtime
- トップ候補に応じた犬種別表情アイコン表示

## 製品の位置づけ
- このアプリは `解釈` と `感情推定` のためのツールです。
- 科学的に検証済みの厳密な犬語翻訳をうたうものではありません。
- 人の言葉を犬っぽい声に変換する reverse 機能の実装は残していますが、公開 UI では非表示です。

## リリース形式
配布対象は zip 配布ではなく、Windows インストーラです。

### インストーラの動作
- デスクトップアプリ本体を `%LocalAppData%\Programs\DogTranslator` に配置
- Flutter アプリ本体と、Dog2vec runtime のブートストラップに必要な最小ソースを同梱
- インストール時に Dog2vec runtime 用アセットを自動取得
  - 組み込み Python runtime
  - Python 依存パッケージ
  - Dog2vec 補助コード
  - Dog2vec モデル重み
- runtime 設定を自動作成
- アンインストール時に runtime 設定とダウンロード済み runtime アセットを削除

### 現在のインストーラ成果物
- ローカル出力先: [dist/installer](D:/AI/WinApp/DogTranslator/dist/installer)
- 想定ファイル名: `DogTranslator-Setup-<version>.exe`

## 開発用コマンド
- 解析: `flutter analyze`
- テスト: `flutter test`
- Windows ビルド: `flutter build windows`
- インストーラ作成: `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`

## Dog2vec runtime 関連
- 開発用ローカル runtime: [dog_voice_local](D:/AI/WinApp/DogTranslator/dog_voice_local)
- リリース向けブートストラップスクリプト: [installer/scripts](D:/AI/WinApp/DogTranslator/installer/scripts)
- アプリ側の runtime 設定探索: [local_inference_runtime.dart](D:/AI/WinApp/DogTranslator/lib/services/local_inference_runtime.dart)

## 主要ドキュメント
- [ToDo.md](D:/AI/WinApp/DogTranslator/ToDo.md)
- [01-requirements/requirements-definition.md](D:/AI/WinApp/DogTranslator/01-requirements/requirements-definition.md)
- [02-specification/specification.md](D:/AI/WinApp/DogTranslator/02-specification/specification.md)
- [03-design/design.md](D:/AI/WinApp/DogTranslator/03-design/design.md)
- [04-implementation/implementation-report.md](D:/AI/WinApp/DogTranslator/04-implementation/implementation-report.md)
- [05-test/test-plan.md](D:/AI/WinApp/DogTranslator/05-test/test-plan.md)
- [06-release/release-plan.md](D:/AI/WinApp/DogTranslator/06-release/release-plan.md)
- [06-release/release-notes-v1.0.0.md](D:/AI/WinApp/DogTranslator/06-release/release-notes-v1.0.0.md)
