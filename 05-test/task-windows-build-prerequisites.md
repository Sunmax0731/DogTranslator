# タスク: Windows ビルド前提解消

## 目的
この環境で `flutter build windows` を通せるように、Visual Studio の不足コンポーネントを特定し、解消手順を整理する。

## 現在の問題
- Flutter が必要な Visual Studio C++ toolchain を見つけられない。
- 必要な workload / component が不足している。

## 根拠
- `flutter doctor -v`
- Visual Studio Installer ログ

## 手動解決手順
1. Visual Studio Installer を管理者として起動する。
2. 対象の Visual Studio を変更する。
3. `Desktop development with C++` と必要 component を追加する。
4. `flutter doctor -v` と `flutter build windows` を再実行する。

## 完了条件
- `flutter doctor -v` が Windows desktop 開発に必要な Visual Studio 構成を認識する。
- `flutter build windows` が成功する。
