# DogTranslator テスト計画

## 1. 対象範囲
Windows MVP+ に対して、forward 解釈、設定 / プロフィール操作、進捗表示、履歴再生 / 検索 / 削除、ダッシュボード連動、ローカル推論連携、Windows ビルド成功までを検証する。

## 2. 自動テスト
### Unit Tests
- WAV からの音声特徴量抽出
- 音声特徴量からの意図分類
- 拡張特徴量込みの確信度 / 候補順位付け
- reverse translator のドメイン挙動保持
- analytics summary 生成
- JSON repository 永続化
- local process inference JSON マッピング
- 推論モデル選択とフォールバック解決

### Widget Tests
- Settings タブの存在
- テーマ / 推論設定 UI の描画
- 履歴 / ダッシュボードを含むアプリ shell 描画

## 3. 手動回帰チェックリスト
1. Windows 上でアプリを起動する。
2. ナビゲーションが `Forward` / `Dashboard` / `Settings` を持つことを確認する。
3. 旧 reverse タブが表示されないことを確認する。
4. 録音画面側ショートカットから犬プロフィールを追加する。
5. Settings でもプロフィールの追加 / 編集 / 削除ができることを確認する。
6. マイク録音を開始し、停止する。
7. 録音中に波形が表示されることを確認する。
8. 解析結果に日本語の感情ラベル、候補円グラフ、鳴き方種別、文脈ヒント、valence / arousal、品質ガイドが表示されることを確認する。
9. Dog2vec ローカル推論で別の解析を行い、段階的な進捗文言、複数段階で進む progress bar、推定残り時間、解析中の結果カード半透明化を確認する。
10. result chip にホバーし、ツールチップが出ることを確認する。
11. 低 / 中 / 高で確信度色が変わり、推論方式ラベルが表示されることを確認する。
12. RMS / Peak / Arousal / Valence がミニグラフで描画されることを確認する。
13. ラジオボタンでフィードバックラベルを保存する。
14. 履歴検索で対象が絞り込まれることを確認する。
15. 感情タグ / プロフィールタグで履歴を絞り込めることを確認する。
16. 保存済み forward セッションをクリックし、メイン結果エリアへ復元されることを確認する。
17. 履歴の `再生` で録音再生が始まることを確認する。
18. 履歴項目を 1 件削除し、消えることを確認する。
19. 破棄してよい状態で一括削除を実行し、履歴が消えることを確認する。
20. Dashboard の感情項目をクリックし、履歴フィルタへ反映されることを確認する。
21. Dashboard のプロフィールフィルタを切り替え、集計がそのプロフィールだけに変わることを確認する。
22. Settings で解析タブではなく設定タブ側から入力マイクを選べることを確認する。
23. 最新録音をプロフィール補正サンプルとして追加する。
24. Settings でテーマを切り替え、ダークモードも確認する。
25. 推論モデルを切り替え、状態メッセージが変わることを確認する。
26. 任意で `dog2vec_runtime.json` がある状態を作り、provider label が local runtime に切り替わることを確認する。
27. インストーラでアプリを導入し、アンインストーラで runtime 設定が片付くことを確認する。

## 4. 実行コマンド
- 作業ディレクトリ: リポジトリ root
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Install-Dog2vecRuntime.ps1 -?`
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Uninstall-Dog2vecRuntime.ps1 -?`
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`

## 5. 期待結果
- テストはコンパイルエラーなく通る。
- Windows ビルドが成功する。
- 公開 UI は forward 中心で、reverse タブは出ない。
- プロフィール、履歴、設定がローカル永続化される。
- 履歴から保存済み録音を再生できる。
- 履歴クリックでメイン結果が復元される。
- 検索、感情タグ、プロフィールで履歴を絞り込める。
- 解析中に意味のある進捗表示が出る。
- 弱い音声や失敗ケースでも落ちない。
- Dog2vec ローカル runtime が利用可能な場合は動作する。
- Windows インストーラがコンパイルできる。

## 6. リスクの高い領域
- 実マイクデバイス挙動は機種差が大きい。
- ヒューリスティック解釈は近似である。
- Dog2vec runtime は、まだ製品専用 classifier head を持たない。
- Python runtime の再配布は今後も検証余地がある。

## 7. 実測結果
- `flutter analyze`: 成功
- `flutter test`: 成功
- `flutter build windows`: 成功
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`: 成功
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Install-Dog2vecRuntime.ps1 -?`: 成功
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Uninstall-Dog2vecRuntime.ps1 -?`: 成功
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`: 成功
- Dog2vec base weight を `dog_voice_local/models/dog2vec/dog2vec_130k_9.pt` へ配置済み
- 実行ファイルを `build/windows/x64/runner/Release/dog_translator.exe` に生成
- インストーラを `dist/installer/DogTranslator-Setup-1.0.0.exe` に生成
- インストーラスモークテスト: 成功
- アンインストーラスモークテスト: 成功
