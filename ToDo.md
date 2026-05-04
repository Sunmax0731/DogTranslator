# DogTranslator ToDo

## プロジェクト概要
- 製品名: DogTranslator
- 目的: 犬の鳴き声を解釈する Windows MVP を構築し、その後 Android / iPhone へ共通コアを広げる。
- 進め方: 工程ごとの文書と task ファイルを使うタスク駆動開発。

## マイルストーン
1. `01-requirements`: MVP の範囲と制約を定義
2. `02-specification`: 具体的な挙動と受け入れ条件を定義
3. `03-design`: 技術選定とアーキテクチャを定義
4. `04-implementation`: Windows MVP を実装
5. `05-test`: 挙動を検証し、根拠を記録
6. `06-release`: 配布形式を整備し、リリースを公開

## 現在の状態
- `01-requirements`: 完了
- `02-specification`: 完了
- `03-design`: 完了
- `04-implementation`: 完了
- `05-test`: 完了
- `06-release`: 完了

## 主な実施タスク
- [x] リポジトリ運用文書 (`Agents.md`, ルート `Skill.md`, 工程別 `Skill.md`) を整備
- [x] マイルストーン文書と工程別スケルトンを作成
- [x] Flutter ベースの Windows MVP を実装
- [x] 自動検証を実施
- [x] Windows ビルド環境の前提を解消し、デスクトップビルドを完了
- [x] 波形表示、入力マイク選択、日本語感情ラベル強化などのリリース前拡張を実施
- [x] 犬種考慮の reverse 制御と音声合成プリセットを実装
- [x] 永続化、プロフィール、ダッシュボード、候補順位付け、推論抽象化を追加
- [x] Dog2vec 導入を見据えた forward 推論の段階化を実施
- [x] ローカルプロセス推論ブリッジと安全なフォールバックを追加
- [x] 音声特徴量拡張とスコア調整で forward 精度を改善
- [x] 推論モデル選択 UI と runtime 状態に応じた切替を追加
- [x] 公開 UI を forward 中心へ整理し、reverse UI を非表示化
- [x] 設定タブ、テーマ切替、履歴操作、結果ツールチップを追加
- [x] プロフィール補正、候補円グラフ、犬種別表情表示を追加
- [x] Dog2vec ローカル runtime アセットを取得し、Python runtime 経路を検証
- [x] 解析進捗 UI を段階表示、残り時間、半透明化で強化
- [x] 履歴タグ絞り込み、結果再表示、GUI 削除導線を追加
- [x] ダッシュボードからの履歴絞り込みとプロフィール別集計を追加
- [x] 入力マイク選択を Settings へ移し、ダークモードを追加
- [x] インストーラ前提のリリース設計と Dog2vec bootstrap 方式を定義
- [x] ローカルインストーラ成果物と runtime クリーンアップスクリプトを作成
- [x] GitHub リポジトリ公開と `v1.0.0` リリースを完了

## ブランチ方針
- ベースブランチ: `main`
- タスクブランチ: `codex/<phase>-<task-summary>`
- 同時稼働する `main` 以外のブランチは原則 2 本以内
- 完了したタスクブランチは `main` へ戻してから次へ進む

## これまでの主な進行順序
1. `codex/docs-foundation`: 文書基盤と計画の整備
2. `codex/flutter-mvp`: Windows MVP の実装と検証
3. `codex/release-prep-installer`: インストーラ中心のリリース準備と runtime bootstrap

## メモ
- 公開済み GitHub リポジトリ: [DogTranslator](https://github.com/Sunmax0731/DogTranslator)
- 初期の「翻訳」表現は、科学的事実ではなく解釈・推定として扱う。
- 現在の配布形式は、アプリ本体導入後に Dog2vec runtime アセットを取得する Windows インストーラです。
