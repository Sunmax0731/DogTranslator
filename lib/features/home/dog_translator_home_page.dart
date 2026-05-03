import 'dart:io';

import 'package:dog_translator/domain/audio_feature_extractor.dart';
import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/domain/reverse_translator.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorHomePage extends StatefulWidget {
  const DogTranslatorHomePage({
    required this.recordingService,
    required this.playbackService,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final int initialTabIndex;

  @override
  State<DogTranslatorHomePage> createState() => _DogTranslatorHomePageState();
}

class _DogTranslatorHomePageState extends State<DogTranslatorHomePage> {
  final AudioFeatureExtractor _featureExtractor = const AudioFeatureExtractor();
  final DogIntentInterpreter _interpreter = const DogIntentInterpreter();
  final ReverseTranslator _reverseTranslator = ReverseTranslator();
  final TextEditingController _textController = TextEditingController();
  final List<HistoryEntry> _history = <HistoryEntry>[];

  TranslationResult? _translationResult;
  ReverseTranslationResult? _reverseResult;
  bool _busy = false;
  String? _statusMessage;

  @override
  void dispose() {
    _textController.dispose();
    widget.recordingService.dispose();
    widget.playbackService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      if (widget.recordingService.isRecording) {
        final path = await widget.recordingService.stop();
        if (path == null || !await File(path).exists()) {
          setState(() {
            _statusMessage = '録音ファイルを取得できませんでした。';
          });
          return;
        }

        final bytes = await File(path).readAsBytes();
        final features = _featureExtractor.extractFromWavBytes(bytes);
        final result = _interpreter.interpret(features);

        setState(() {
          _translationResult = result;
          _history.insert(
            0,
            HistoryEntry(
              mode: InteractionMode.forward,
              title: result.intent.labelJa,
              subtitle: result.explanation,
              timestamp: DateTime.now(),
            ),
          );
          _statusMessage = '録音を解析しました。';
        });
      } else {
        final hasPermission = await widget.recordingService.hasPermission();
        if (!hasPermission) {
          setState(() {
            _statusMessage = 'マイクへのアクセスが許可されていません。';
          });
          return;
        }
        await widget.recordingService.start();
        setState(() {
          _statusMessage = '録音中です。もう一度押すと解析します。';
        });
      }
    } on FormatException catch (error) {
      setState(() {
        _statusMessage = '録音の解析に失敗しました: ${error.message}';
      });
    } catch (error) {
      setState(() {
        _statusMessage = '録音処理でエラーが発生しました: $error';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _runReverseTranslation() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final result = _reverseTranslator.translate(_textController.text);
      await widget.playbackService.play(result.audioBytes);
      setState(() {
        _reverseResult = result;
        _history.insert(
          0,
          HistoryEntry(
            mode: InteractionMode.reverse,
            title: result.style.labelJa,
            subtitle: result.dogText,
            timestamp: DateTime.now(),
          ),
        );
        _statusMessage = '犬語っぽい音声を再生しました。';
      });
    } catch (error) {
      setState(() {
        _statusMessage = '逆変換の再生でエラーが発生しました: $error';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final historyPanel = _HistoryPanel(history: _history);
          final main = Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF115E59),
                      Color(0xFF134E4A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DogTranslator',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '犬語の「翻訳」ではなく、鳴き声の傾向から感情や意図を推定する Windows MVP です。',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          labelColor: Color(0xFF134E4A),
                          unselectedLabelColor: Colors.white,
                          tabs: [
                            Tab(text: '犬の声 -> 人の言葉'),
                            Tab(text: '人の言葉 -> 犬っぽい声'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TabBarView(
                    children: [
                      _ForwardTranslatorTab(
                        result: _translationResult,
                        isRecording: widget.recordingService.isRecording,
                        busy: _busy,
                        statusMessage: _statusMessage,
                        onRecordPressed: _toggleRecording,
                      ),
                      _ReverseTranslatorTab(
                        controller: _textController,
                        result: _reverseResult,
                        busy: _busy,
                        statusMessage: _statusMessage,
                        onTranslatePressed: _runReverseTranslation,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (constraints.maxWidth > 1024) {
            return Scaffold(
              body: Row(
                children: [
                  Expanded(flex: 3, child: main),
                  SizedBox(
                    width: 360,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                      child: historyPanel,
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: Column(
              children: [
                Expanded(child: main),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(height: 240, child: historyPanel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ForwardTranslatorTab extends StatelessWidget {
  const _ForwardTranslatorTab({
    required this.result,
    required this.isRecording,
    required this.busy,
    required this.statusMessage,
    required this.onRecordPressed,
  });

  final TranslationResult? result;
  final bool isRecording;
  final bool busy;
  final String? statusMessage;
  final VoidCallback onRecordPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forward Interpretation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('短い録音から音量・長さ・勢いを見て、感情や意図の傾向を推定します。'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy ? null : onRecordPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: isRecording
                        ? const Color(0xFFB91C1C)
                        : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                  icon: Icon(isRecording ? Icons.stop_circle : Icons.mic),
                  label: Text(isRecording ? '録音を止めて解析' : '録音を開始'),
                ),
                const SizedBox(height: 12),
                Text(
                  statusMessage ?? 'マイクボタンを押して録音を始めてください。',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? const Text('まだ解析結果がありません。録音後にここへ結果を表示します。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result!.intent.labelJa,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(result!.explanation),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FeatureChip(
                            label: '確信度',
                            value: result!.confidence.labelJa,
                          ),
                          _FeatureChip(
                            label: '録音長',
                            value:
                                '${result!.features.durationSeconds.toStringAsFixed(2)}s',
                          ),
                          _FeatureChip(
                            label: 'RMS',
                            value: result!.features.rms.toStringAsFixed(3),
                          ),
                          _FeatureChip(
                            label: 'Peak',
                            value: result!.features.peak.toStringAsFixed(3),
                          ),
                          _FeatureChip(
                            label: 'Burst',
                            value: result!.features.burstCount.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReverseTranslatorTab extends StatelessWidget {
  const _ReverseTranslatorTab({
    required this.controller,
    required this.result,
    required this.busy,
    required this.statusMessage,
    required this.onTranslatePressed,
  });

  final TextEditingController controller;
  final ReverseTranslationResult? result;
  final bool busy;
  final String? statusMessage;
  final VoidCallback onTranslatePressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reverse Expression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('日本語または英語の短い文を、犬っぽい鳴き声表現と音声に変換します。'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '例: こっちに来て / Let us play together!',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: busy ? null : onTranslatePressed,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('犬っぽい声に変換して再生'),
                ),
                const SizedBox(height: 12),
                Text(statusMessage ?? '入力後に再生すると犬語っぽい音声を合成します。'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? const Text('まだ逆変換結果がありません。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result!.style.labelJa,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        result!.dogText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(result!.explanation),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.history});

  final List<HistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Text('まだ履歴はありません。録音または逆変換を行うとここに表示されます。')
            else
              Expanded(
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: entry.mode == InteractionMode.forward
                              ? const Color(0xFFCCFBF1)
                              : const Color(0xFFFDE68A),
                          foregroundColor: const Color(0xFF134E4A),
                          child: Icon(
                            entry.mode == InteractionMode.forward
                                ? Icons.pets
                                : Icons.record_voice_over,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(entry.subtitle),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(entry.timestamp),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
