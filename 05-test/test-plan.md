# DogTranslator Test Plan

## 1. Scope
Validate the Windows MVP across domain logic, primary UI flows, and Windows desktop build success.

## 2. Automated Tests
### Unit Tests
- Intent classification from derived audio features
- Reverse text to dog-expression mapping
- Low-confidence and fallback handling

### Widget Tests
- Tab switching
- Reverse translation flow
- Session history rendering

## 3. Manual Tests
1. Launch app on Windows.
2. Confirm forward translation screen opens.
3. Start and stop microphone recording.
4. Confirm analysis result appears.
5. Enter Japanese text in reverse mode.
6. Confirm dog-style output and emotion tag appear.
7. Confirm history panel contains both interactions.

## 4. Validation Commands
- Working directory: repository root
- `flutter test`
- `flutter analyze`
- `flutter build windows`

## 5. Expected Results
- Tests pass without compilation errors.
- Windows build completes successfully.
- The app handles missing or weak audio gracefully.

## 6. Known Risk Areas
- Real microphone device behavior may differ by hardware.
- Heuristic interpretation is intentionally approximate.

## 7. Observed Results
- `flutter analyze`: passed
- `flutter test`: passed with 6 tests
- `flutter build windows`: could not complete in the current environment

## 8. Current Blocker
- `flutter doctor -v` reports missing Visual Studio components for Windows desktop builds:
  - Desktop development with C++
  - MSVC build tools
  - C++ CMake tools for Windows
  - Windows 10 SDK
- Detailed recovery task: `05-test/task-windows-build-prerequisites.md`
