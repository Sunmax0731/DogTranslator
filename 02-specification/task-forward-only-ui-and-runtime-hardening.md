# タスク: forward 中心 UI と runtime 安定化

## 目的
公開 UI を forward 解釈中心に整理し、runtime 依存の失敗や未設定時でも利用しやすい状態へ整える。

## 主要論点
- reverse UI を非表示にしつつ実装を保持する。
- runtime 状態やフォールバックをユーザーに分かる形で表示する。
- 履歴、設定、解析フローを forward 中心の導線へ再整理する。

## 完了条件
- 公開 UI が Forward / Dashboard / Settings 中心になっている。
- runtime 状態に応じて安全なフォールバック挙動を確認できる。
