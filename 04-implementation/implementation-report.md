# DogTranslator 実装レポート

## 1. 実装概要
Windows 向けの犬音声解釈アプリとして、録音、波形表示、段階解析、履歴管理、設定管理、Dog2vec ローカル推論連携、インストーラ配布までを一通り実装しました。公開 UI は forward 中心に整理し、reverse 機能はコードベース内に保持したまま非表示にしています。

## 2. 実装した主要機能
- マイク録音と録音停止
- 録音中のライブ波形表示
- 音声特徴量抽出
- ヒューリスティック推論
- Dog2vec ローカル runtime 連携
- 推論モデル選択
- 候補円グラフと犬種別表情アイコン
- プロフィール管理
- 個体補正サンプル追加
- Session History の検索、再生、絞り込み、削除
- Dashboard の集計と比較表示
- Settings でのテーマ、入力マイク、推論モデル設定
- Windows インストーラと Dog2vec bootstrap / cleanup

## 3. 実装上の重要判断
- 公開製品は forward 中心に絞り、reverse 機能は再利用のため内部保持に留めた。
- 推論は `InferenceProvider` 境界の後ろに置き、heuristic と Dog2vec runtime を差し替え可能にした。
- `HomeController` を中心に状態と非同期フローをまとめ、UI widget は責務別に分割した。
- 重いモデルデータはベースインストーラから外し、インストール時に取得する方式を採用した。

## 4. 主な構成要素
### Presentation
- `lib/features/home/dog_translator_home_page.dart`
- `lib/features/home/home_controller.dart`
- `lib/features/home/widgets/*`

### Domain
- `lib/domain/audio_feature_extractor.dart`
- `lib/domain/dog_intent_interpreter.dart`
- `lib/domain/inference_provider.dart`
- `lib/domain/analytics_service.dart`
- `lib/domain/models/*`

### Service / Adapter
- `lib/services/record_recording_service.dart`
- `lib/services/json_file_app_repository.dart`
- `lib/services/local_process_inference_provider.dart`
- `lib/services/resilient_inference_provider.dart`
- `lib/services/inference_provider_factory.dart`
- `lib/services/local_inference_runtime.dart`

### Release / Installer
- `installer/DogTranslator.iss`
- `installer/scripts/Install-Dog2vecRuntime.ps1`
- `installer/scripts/Uninstall-Dog2vecRuntime.ps1`
- `tools/build_release_installer.ps1`

## 5. 解析フロー
1. 録音音声を保存
2. WAV / PCM を読み込む
3. 音声特徴量を抽出
4. 品質ヒントを生成
5. 選択中 provider で推論
6. 個体補正を反映
7. 結果を保存し、履歴へ追加
8. UI に主解釈、候補、主要パラメータ、可視化を表示

## 6. Dog2vec 連携の実装状態
- アプリ側はローカルプロセス連携に対応済み
- `dog2vec_runtime.json` と runtime root を自動探索できる
- インストーラは Dog2vec runtime を post-install で取得・構成する
- 現状は base 埋め込みモデルとアプリ側マッピングの組み合わせであり、製品専用 classifier head は未搭載

## 7. UI / UX 実装方針
- Hero を廃止し、WinUI3 に寄せた落ち着いたカード中心構成に変更
- ダークモードと複数テーマに対応
- 解析中は進捗バー、段階文言、推定残り時間、結果カードの半透明化を行う
- 結果カードでは主要パラメータのツールチップ、色、グラフを使って理解しやすくした

## 8. 永続化
ローカル JSON リポジトリで以下を保持する。
- プロフィール
- 設定
- forward 履歴
- フィードバック
- 個体補正集計

## 9. 残課題
- Dog2vec 専用の学習済み classifier head を導入して精度を上げる
- 個体補正ロジックをさらに洗練する
- Android / iPhone 展開時の runtime 置換戦略を整理する

## 10. ビルド / 配布成果物
- Windows 実行ファイル: `build/windows/x64/runner/Release/dog_translator.exe`
- インストーラ: `dist/installer/DogTranslator-Setup-1.0.0.exe`
- GitHub リリース: `v1.0.0`
