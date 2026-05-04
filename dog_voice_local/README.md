# Dog Voice Local Runtime

このフォルダは、DogTranslator 用のローカル Python 推論 runtime を保持します。

## 動作モード
- Bootstrap mode: Dog2vec 重みが未導入でも、WAV から手作り推論を実行する
- Dog2vec-enhanced mode: `models/dog2vec/dog2vec_130k_9.pt` が存在し、Python 依存が入っている場合、Dog2vec を読み込んで埋め込みを作成し、その後 JSON 形式の推論結果を返す

## 想定エントリポイント
- `python app/infer.py --input <wav-path>`

## 開発時の bootstrap 手順
1. `requirements.txt` から Python パッケージをインストールする
2. `tools/bootstrap_runtime.ps1` を実行し、upstream Dog2vec 補助コードの取得と、必要であれば重みファイルのダウンロードを行う
3. 必要に応じて repo root に `dog2vec_runtime.example.json` を `dog2vec_runtime.json` として配置する

## リリース版インストーラの bootstrap
- Windows インストーラには Dog2vec 重みファイルを同梱しない
- インストーラ bootstrap は `release-requirements.txt` と `installer/scripts/Install-Dog2vecRuntime.ps1` を使う
- runtime アセットはインストール時に LocalAppData 配下の runtime ワークスペースへ構成される

## 現在の制約
- 重みファイルが無くても runtime 自体は動作するが、その場合の出力は heuristic 優先になる
- upstream Dog2vec base model は利用できるが、タスク専用 classifier head はこのリポジトリには含まれない
