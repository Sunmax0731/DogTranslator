# DogTranslator 設計書

## 1. UX 候補
### Option A: Hero 主導のマルチモード着地画面
- 長所: 初見の印象が強い
- 短所: 縦空間を消費し、非表示 reverse 機能を過剰に目立たせる

### Option B: WinUI3 風の実用ワークスペース
- 長所: 落ち着いた情報階層、繰り返し利用に向く、Windows アプリ慣習に近い
- 短所: 宣伝的な派手さは弱い

### Option C: 高密度な分析コンソール
- 長所: パワーユーザー向き
- 短所: カジュアルユーザーには圧が強い

## 2. UX 判断
- 採用方針: Option B
- 理由: このアプリは forward 中心のユーティリティになったため、Hero 起点の見せ方より実用ワークスペースの方が適している。

## 3. 採用デザインパターン
### Presentation Controller
- `HomeController` が画面状態、非同期フロー、永続化トリガ、runtime 解決を持つ。

### Widget Composition
- Home UI は以下の小さい widget に分割する。
  - `ForwardTranslatorTab`
  - `DashboardTab`
  - `SettingsTab`
  - `HistoryPanel`
  - `WaveformPanel`
  - `CreateProfileDialog`
  - `CandidatePieChart`

### Hidden Feature Preservation
- reverse 向け widget / service はコンパイル対象に残すが、ルーティングで公開しない。

### Barrel Export for Domain Models
- `lib/domain/models.dart` から、`lib/domain/models/` 下の小さなモデル群を export する。

## 4. レイヤードアーキテクチャ
- Presentation layer:
  - Flutter pages / widgets
- Application layer:
  - `HomeController`
- Domain layer:
  - feature extraction
  - inference provider contract
  - heuristic forward interpreter
  - reverse translator
  - analytics summarizer
- Service / adapter layer:
  - recording service
  - persistence repository
  - playback service
  - local process inference bridge

## 5. WinUI3 指向の UI 構成
- Hero バナーは排除する。
- 静かなコントラストと角丸を持つ surface 分離カードを使う。
- ナビゲーションは常時見える形で明示する。
- 主要アクションは対象データの近くに置く。
- アクセントカラーは装飾ではなく操作と状態表示に使う。
- 設定は専用の Settings 画面に寄せる。

## 6. ナビゲーション設計
### 広いレイアウト
- 左ナビゲーションレールカード
- 中央コンテンツカード群
- 右 Session History カード

### 狭いレイアウト
- 下部 `NavigationBar`
- 先にコンテンツ、後に履歴をスクロールへ積む

### 公開ページ
- Forward
- Dashboard
- Settings

## 7. 推論アーキテクチャ
- `InferenceProvider` は非同期かつ raw-audio aware を維持する。
- 既定経路:
  - `DogIntentInterpreter`
- 拡張経路:
  - `LocalProcessInferenceProvider`
- 耐障害 wrapper:
  - `ResilientInferenceProvider`
- 起動時解決:
  - `InferenceProviderFactory`

## 8. Dog2vec 統合戦略
### Option A: Flutter アプリ内部へ直接組み込む
- 長所: 単一プロセス
- 短所: サイズが重く、配布が難しい

### Option B: ローカル Python / モデルプロセス連携
- 長所: Windows では現実的、Flutter 本体を軽く保てる、設計メモと整合する
- 短所: 外部依存とモデルアセットが必要

### Option C: クラウド推論サービス
- 長所: クライアントが薄い
- 短所: プライバシーとオフライン性で不利

### 採用案
- Option B

## 9. ローカル runtime 境界
- Flutter は Dog2vec 重みをアプリコード内へ同梱しない。
- runtime アセットは `dog_voice_local/` に置く。
- 設定は `dog2vec_runtime.json` で持つ。
- runtime は以下の動作モードを取りうる。
  - bootstrap heuristic mode
  - Dog2vec-enhanced embedding mode
- Flutter 側は正規化済み JSON 出力だけを消費する。

## 10. 個体補正設計
- 個体補正はプロフィール集計値として保持する。
  - average pitch
  - average RMS
  - average activity ratio
  - sample count
- `DogIntentInterpreter` は、選択中プロフィールとの類似度を小さなスコア補正として利用する。
- これにより、完全な再学習を避けつつ、ローカルで安価なパーソナライズを実現する。

## 11. 状態の責務分担
- `HomeController` が持つ状態:
  - selected inference model
  - effective active inference model
  - inference runtime status message
  - selected theme preset
  - active profile
  - active scene mode
  - selected microphone
  - waveform buffer
  - current forward result
  - saved history
  - dashboard comparison selection

## 12. 履歴操作設計
- 公開 UI の履歴は forward レコード中心で扱う。
- 各履歴項目はクリックで結果再表示、再生も可能。
- 検索はローカル・クライアント側で軽量に行う。
- 長期利用に備え、日付 + 時刻を表示する。

## 13. Settings 設計
- 共通設定とプロフィール管理は意図的にまとめる。
- 録音画面側のプロフィール追加導線はショートカットとして残す。
- Settings は何でも置き場にせず、アプリ全体に関わる設定と durable なプロフィール操作だけを入れる。

## 14. モバイル展開準備
- 非表示 reverse コードは将来戻せるよう分離を維持する。
- 推論は契約の後ろに置き、将来 ONNX / Sentis / TFLite 互換実行へ差し替えられるようにする。
- UI 状態フローは、デスクトップ専用ナビゲーションへ強く結合しない。

## 15. リリース/パッケージング設計
### Option A: zip 単体のデスクトップビルド
- 長所: 単純
- 短所: runtime セットアップを案内しにくい

### Option B: インストーラ + post-install runtime bootstrap
- 長所: モデル重みをベースパッケージから外せる、セットアップを自動化できる、アンインストール削除も明示できる
- 短所: インストール時にネット接続が必要

### Option C: 完全同梱のオフラインインストーラ
- 長所: ダウンロード後はオフラインで完結
- 短所: パッケージが大きい

### 採用案
- Option B

### リリース runtime 配置
- アプリ本体はインストールディレクトリ配下に置く。
- Dog2vec runtime は LocalAppData 配下に置き、管理者権限なしで書き込み可能にする。
- runtime 探索は以下を優先順でサポートする。
  - 明示的な環境変数による config path
  - 明示的な環境変数による runtime root
  - LocalAppData `DogTranslator` の既定パス
