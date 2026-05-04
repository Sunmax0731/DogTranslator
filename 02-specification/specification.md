# DogTranslator 仕様書

## 1. 機能セット
- Forward モード: マイク音声 -> 段階解析 -> 候補順位付きの解釈結果
- Dashboard: ローカル集計と比較支援
- Settings: アプリ共通設定とプロフィール管理
- Session History: ローカル永続化された forward 履歴の検索と再生
- 録音中のライブ波形 / レベル表示
- Windows 用の入力マイク選択
- 推論モデル選択: auto / heuristic / dog2vec_local
- Python プロセス経由の任意の Dog2vec ローカル runtime
- reverse 実装はコードベースに残すが、公開 UI には出さない

## 2. 画面遷移 / ナビゲーション
- 広いレイアウト:
  - 左ナビゲーションカード
  - 中央メインコンテンツ
  - 右側履歴パネル
- 狭いレイアウト:
  - 下部ナビゲーション
  - 縦積みの履歴セクション
- 表示対象:
  - `Forward`
  - `Dashboard`
  - `Settings`

## 3. Forward モードの挙動
### 入力
- ユーザーが録音を手動開始する。
- ユーザーが録音を手動停止する。
- 録音前に入力マイクを選べる。
- 必要に応じて犬プロフィールとシーンモードを選べる。

### 解析パイプライン
1. 録音した PCM 音声を読み込む。
2. 録音長、RMS、Peak、Zero Crossing Rate、Dynamic Range、Spectral Centroid、High-band Ratio、Crest Factor、Activity Ratio、Pitch 推定を計算する。
3. 録音品質ヒントを生成する。
4. 犬音声検出ゲートを通す。
5. 選択中の推論 provider を実行する。
6. 選択プロフィールに補正データがある場合は類似度補正をかける。
7. 主解釈、候補順位、鳴き方種別、文脈ヒント、valence / arousal、説明文、確信度、推論方式ラベルを生成する。

### 出力
- 主解釈ラベル
- 日本語の感情ラベル
- 説明文
- 確信度: `high` / `medium` / `low`
- 候補順位
- 候補円グラフ
- 鳴き方種別
- 文脈ヒント
- valence / arousal 数値
- 特徴量サマリ
- 品質ヒント

## 4. 結果パラメータの説明
結果カードでホバー時に、confidence、provider、vocal type、context、duration、RMS、peak、pitch、valence、arousal の説明を出す。

## 5. forward 感情カテゴリ
- `excited_greeting`
- `attention_seeking`
- `warning_alert`
- `anxious_whine`
- `sleepy`
- `restless_energy`
- `happy_relaxed`
- `bored`
- `uncertain`

## 6. 追加分類軸
### 鳴き方種別
- `bark`
- `growl`
- `whine`
- `howl`
- `yelp`
- `pant`
- `mixed`
- `unknown`

### 文脈ヒント
- `stranger_or_noise`
- `owner_return`
- `food_or_attention`
- `walk_anticipation`
- `play`
- `alone`
- `other_dog`
- `conflict`
- `unknown`

## 7. 録音可視化と品質
- 録音中はライブ波形、またはバー状のレベル表示を出す。
- 新しい録音開始時に可視化をリセットする。
- 品質ヒントの例:
  - 録音が短すぎる
  - レベルが弱すぎる
  - Peak が尖りすぎている
  - ノイズ混入または不安定入力の可能性

## 8. プロフィールと個体補正
### 犬プロフィール項目
- profile id
- 表示名
- 犬種
- 年齢ステージ
- サイズ区分
- メモ
- 任意の個体補正集計:
  - サンプル数
  - 平均 pitch
  - 平均 RMS
  - 平均 activity ratio
  - 最終補正日時

### 個体補正ルール
- 最新の保存済み forward 録音をプロフィールへ補正サンプルとして追加できる。
- 現フェーズでは、個体補正は集計値更新のみ行う。
- 個体補正は、完全な再学習ではなく、ヒューリスティックの小さなバイアスとして作用させる。

### 対応犬種
- 既存犬種に加え `Pomeranian` を含む

## 9. フィードバック入力
- 保存済み forward レコードに手動フィードバックラベルを保存できる。
- 可視 UI ではドロップダウンではなくラジオボタンを使う。

## 10. Settings タブの挙動
### 共通設定
- テーマプリセット:
  - default
  - ocean
  - sunset
  - forest
  - graphite
  - dark
- 推論モデル:
  - `auto`
  - `heuristic`
  - `dog2vec_local`
- 入力マイク選択

### プロフィール管理
- 追加
- 編集
- 削除
- 最新録音を個体補正サンプルとして追加

## 11. Session History
- forward / reverse の内部履歴は保持できるが、公開 UI の履歴パネルは forward 中心とする。
- 履歴パネルの機能:
  - 検索ボックス
  - 日付 + 時刻表示
  - 保存済み forward 録音の再生
  - 比較対象選択トグル
  - 感情タグ絞り込み
  - プロフィール絞り込み
  - 個別削除
  - 一括削除
- 表示メタデータ:
  - timestamp
  - profile name
  - scene mode
  - primary interpretation
  - short explanation

## 12. Dashboard
- forward 総セッション数
- フィードバック入力数
- プロフィール数
- 感情カテゴリ別集計
- シーン別集計
- 比較対象サマリ
- プロフィールごとの絞り込み
- 感情クリックによる履歴フィルタ連動

## 13. ローカルプロセス推論契約
### 実行方法
- アプリは JSON から任意の runtime 設定を読み込む。
- 設定された command と args でプロセスを起動する。
- 呼び出し時に `--input <wavPath>` を付与する。

### runtime ファイル
- repo root または配布先に置く `dog2vec_runtime.json`
- `dog_voice_local/` runtime フォルダ
- 必要に応じて `dog_voice_local/vendor/dog2vec` の補助コード
- 必要に応じて `dog_voice_local/models/dog2vec/dog2vec_130k_9.pt`

### 期待する stdout JSON
```json
{
  "detected": true,
  "vocal_type": "bark",
  "emotion": { "top": "alert", "score": 0.74 },
  "context": { "top": "stranger_or_noise", "score": 0.62 },
  "valence": -0.22,
  "arousal": 0.81,
  "confidence": 0.68,
  "message": "警戒に近い声の傾向として解釈しました。"
}
```

### フォールバックルール
- 設定ファイル無し: heuristic provider を使う。
- プロセス失敗: heuristic provider を使う。
- 犬音声でない、または弱すぎる入力: uncertain と品質ガイドを返す。

### モデル選択ルール
- `auto`: Dog2vec runtime が構成されていれば優先し、なければ heuristic。
- `heuristic`: 常にアプリ内ヒューリスティックを使う。
- `dog2vec_local`: ローカル Dog2vec runtime を優先し、利用不可時は heuristic へフォールバックし、その状態を UI メッセージで見せる。

## 14. 非表示 reverse 機能の扱い
- reverse 実装はソース管理に残す。
- 公開 UI では以下を出さない:
  - reverse タブ
  - reverse 履歴ビュー
  - reverse 中心のダッシュボード導線
- 将来の再有効化は、再実装ではなく UI 配線で戻せる状態を保つ。

## 15. エラーハンドリング
- マイク未接続: ガイダンスを表示し、録音操作を無効化する。
- 録音が短い: 低確信度 + 品質ヒント付きで返す。
- ファイル解析失敗: セッションは維持しつつ解析エラー表示。
- 再生失敗: 結果は保持し、UI を止めずに失敗だけ通知。
- 選択マイクが使えない: デフォルト入力へ戻し、メッセージを出す。
- 永続化読み込み失敗: ローカル状態を空で再初期化し、警告を出す。
- ローカル推論プロセス失敗: 落ちずに heuristic 推論へフォールバックする。

## 16. 受け入れシナリオ
1. 短く大きな吠え声を録音すると、警戒/挨拶などの候補順位と品質ガイドが出る。
2. ほぼ無音を録音すると、uncertain と低確信度で返る。
3. feature chip にホバーすると説明ツールチップが出る。
4. 入力マイクを切り替えて、選択したデバイスから録音できる。
5. Settings でテーマを切り替えられる。
6. Settings でプロフィールの追加 / 編集 / 削除ができる。
7. 履歴から保存済み forward 録音を再生できる。
8. 履歴検索結果に日付と時刻が表示される。
9. 最新の forward 録音をプロフィールへ補正サンプル追加できる。
10. Dog2vec runtime が JSON を返すと、forward 結果へマッピングされる。
11. reverse 実装は残っているが、公開 UI は Forward / Dashboard / Settings のみを表示する。

## 17. インストーラと runtime bootstrap の挙動
### インストール
- インストール先: `%LocalAppData%\Programs\DogTranslator`
- post-install bootstrap 先:
  - runtime root: `%LocalAppData%\DogTranslator\dog2vec-runtime`
  - config root: `%LocalAppData%\DogTranslator\.dog2vec`
- インストーラ bootstrap が取得するもの:
  - 組み込み Python runtime
  - Dog2vec ローカル推論用 Python パッケージ
  - Dog2vec 補助ソースアーカイブ
  - Dog2vec モデル重みファイル
- runtime JSON とユーザー環境変数を自動作成する。

### アンインストール
- 削除対象:
  - runtime root
  - config root
  - `DOG_TRANSLATOR_RUNTIME_ROOT`
  - `DOG_TRANSLATOR_RUNTIME_CONFIG`
