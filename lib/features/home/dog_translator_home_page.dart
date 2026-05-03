import 'dart:async';
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
  final List<double> _waveformSamples = <double>[];

  StreamSubscription<double>? _amplitudeSubscription;
  TranslationResult? _translationResult;
  ReverseTranslationResult? _reverseResult;
  List<RecordingInputDevice> _inputDevices = const <RecordingInputDevice>[];
  String? _selectedInputDeviceId;
  DogBreed _selectedBreed = DogBreed.mixed;
  bool _recordingBusy = false;
  bool _reverseBusy = false;
  bool _loadingInputDevices = true;
  String? _forwardStatusMessage;
  String? _reverseStatusMessage;

  @override
  void initState() {
    super.initState();
    _selectedInputDeviceId = widget.recordingService.selectedInputDeviceId;
    unawaited(_loadInputDevices());
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _textController.dispose();
    widget.recordingService.dispose();
    widget.playbackService.dispose();
    super.dispose();
  }

  Future<void> _loadInputDevices() async {
    setState(() {
      _loadingInputDevices = true;
    });

    try {
      final devices = await widget.recordingService.listInputDevices();
      if (!mounted) {
        return;
      }
      setState(() {
        _inputDevices = devices;
        final currentId = _selectedInputDeviceId;
        if (currentId != null &&
            devices.every((device) => device.id != currentId)) {
          _selectedInputDeviceId = null;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _forwardStatusMessage = '入力マイク一覧の取得に失敗しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingInputDevices = false;
        });
      }
    }
  }

  Future<void> _selectInputDevice(String? deviceId) async {
    if (_recordingBusy || widget.recordingService.isRecording) {
      return;
    }

    await widget.recordingService.selectInputDevice(deviceId);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedInputDeviceId = deviceId;
      _forwardStatusMessage = deviceId == null
          ? '既定のマイクを使う設定にしました。'
          : '入力マイクを切り替えました。';
    });
  }

  Future<void> _toggleRecording() async {
    if (_recordingBusy) {
      return;
    }

    setState(() {
      _recordingBusy = true;
      _forwardStatusMessage = null;
    });

    try {
      if (widget.recordingService.isRecording) {
        await _amplitudeSubscription?.cancel();
        _amplitudeSubscription = null;

        final path = await widget.recordingService.stop();
        if (path == null || !await File(path).exists()) {
          setState(() {
            _forwardStatusMessage = '録音ファイルを取得できませんでした。';
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
          _forwardStatusMessage = '録音を解析しました。';
        });
      } else {
        final hasPermission = await widget.recordingService.hasPermission();
        if (!hasPermission) {
          setState(() {
            _forwardStatusMessage = 'マイクへのアクセスが許可されていません。';
          });
          return;
        }

        await widget.recordingService.selectInputDevice(_selectedInputDeviceId);
        await widget.recordingService.start();
        _beginWaveformSampling();

        setState(() {
          _waveformSamples
            ..clear()
            ..addAll(List<double>.filled(48, 0));
          _forwardStatusMessage = '録音中です。もう一度押すと解析します。';
        });
      }
    } on FormatException catch (error) {
      setState(() {
        _forwardStatusMessage = '録音解析に失敗しました: ${error.message}';
      });
    } catch (error) {
      setState(() {
        _forwardStatusMessage = '録音処理でエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _recordingBusy = false;
        });
      }
    }
  }

  void _beginWaveformSampling() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = widget.recordingService.amplitudeStream().listen((
      value,
    ) {
      if (!mounted || !widget.recordingService.isRecording) {
        return;
      }
      setState(() {
        if (_waveformSamples.length >= 48) {
          _waveformSamples.removeAt(0);
        }
        _waveformSamples.add(value.clamp(0.0, 1.0));
      });
    });
  }

  Future<void> _runReverseTranslation() async {
    if (_reverseBusy) {
      return;
    }

    setState(() {
      _reverseBusy = true;
      _reverseStatusMessage = null;
    });

    try {
      final result = _reverseTranslator.translate(
        _textController.text,
        breed: _selectedBreed,
      );
      setState(() {
        _reverseResult = result;
        _history.insert(
          0,
          HistoryEntry(
            mode: InteractionMode.reverse,
            title: '${result.style.labelJa} (${result.breed.labelJa})',
            subtitle: result.dogText,
            timestamp: DateTime.now(),
          ),
        );
        _reverseStatusMessage = '犬っぽい結果を生成しました。音声再生を試します。';
      });

      unawaited(_playReverseAudio(result));
    } catch (error) {
      setState(() {
        _reverseStatusMessage = '逆変換の生成でエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _reverseBusy = false;
        });
      }
    }
  }

  Future<void> _playReverseAudio(ReverseTranslationResult result) async {
    try {
      await widget.playbackService.play(result.audioBytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _reverseStatusMessage = '犬っぽい音声を再生しました。';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reverseStatusMessage = '結果は生成しましたが、音声再生に失敗しました: $error';
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
          final mainContent = Column(
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
                        busy: _recordingBusy,
                        loadingInputDevices: _loadingInputDevices,
                        statusMessage: _forwardStatusMessage,
                        waveformSamples: _waveformSamples,
                        inputDevices: _inputDevices,
                        selectedInputDeviceId: _selectedInputDeviceId,
                        onInputDeviceSelected: _selectInputDevice,
                        onRefreshInputDevices: _loadInputDevices,
                        onRecordPressed: _toggleRecording,
                      ),
                      _ReverseTranslatorTab(
                        controller: _textController,
                        result: _reverseResult,
                        busy: _reverseBusy,
                        selectedBreed: _selectedBreed,
                        statusMessage: _reverseStatusMessage,
                        onBreedChanged: (breed) {
                          if (breed == null) {
                            return;
                          }
                          setState(() {
                            _selectedBreed = breed;
                          });
                        },
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
                  Expanded(flex: 3, child: mainContent),
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
                Expanded(child: mainContent),
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
    required this.loadingInputDevices,
    required this.statusMessage,
    required this.waveformSamples,
    required this.inputDevices,
    required this.selectedInputDeviceId,
    required this.onInputDeviceSelected,
    required this.onRefreshInputDevices,
    required this.onRecordPressed,
  });

  final TranslationResult? result;
  final bool isRecording;
  final bool busy;
  final bool loadingInputDevices;
  final String? statusMessage;
  final List<double> waveformSamples;
  final List<RecordingInputDevice> inputDevices;
  final String? selectedInputDeviceId;
  final ValueChanged<String?> onInputDeviceSelected;
  final VoidCallback onRefreshInputDevices;
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
                const Text('録音した犬の鳴き声から、感情や意図を日本語で推定します。'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedInputDeviceId,
                        decoration: const InputDecoration(
                          labelText: '入力マイク',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('既定のマイク'),
                          ),
                          ...inputDevices.map(
                            (device) => DropdownMenuItem<String?>(
                              value: device.id,
                              child: Text(device.label),
                            ),
                          ),
                        ],
                        onChanged: loadingInputDevices || busy || isRecording
                            ? null
                            : onInputDeviceSelected,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'マイク一覧を更新',
                      onPressed: loadingInputDevices || busy || isRecording
                          ? null
                          : onRefreshInputDevices,
                      icon: loadingInputDevices
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WaveformPanel(
                  isRecording: isRecording,
                  waveformSamples: waveformSamples,
                ),
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
    required this.selectedBreed,
    required this.statusMessage,
    required this.onBreedChanged,
    required this.onTranslatePressed,
  });

  final TextEditingController controller;
  final ReverseTranslationResult? result;
  final bool busy;
  final DogBreed selectedBreed;
  final String? statusMessage;
  final ValueChanged<DogBreed?> onBreedChanged;
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
                const Text('人の言葉を犬っぽい鳴き声表現と音声に変換します。犬種プリセットも選べます。'),
                const SizedBox(height: 16),
                DropdownButtonFormField<DogBreed>(
                  initialValue: selectedBreed,
                  decoration: const InputDecoration(
                    labelText: '犬種プリセット',
                    border: OutlineInputBorder(),
                  ),
                  items: DogBreed.values
                      .map(
                        (breed) => DropdownMenuItem<DogBreed>(
                          value: breed,
                          child: Text(
                            '${breed.labelJa} - ${breed.descriptionJa}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onBreedChanged,
                ),
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
                        '${result!.style.labelJa} / ${result!.breed.labelJa}',
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

class _WaveformPanel extends StatelessWidget {
  const _WaveformPanel({
    required this.isRecording,
    required this.waveformSamples,
  });

  final bool isRecording;
  final List<double> waveformSamples;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRecording ? '録音波形' : '録音待機中',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: waveformSamples.isEmpty
                ? Center(
                    child: Text(
                      '録音を開始すると波形を表示します。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : CustomPaint(
                    painter: _WaveformPainter(samples: waveformSamples),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.samples});

  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / (samples.length * 1.8);

    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      baselinePaint,
    );

    if (samples.isEmpty) {
      return;
    }

    final step = size.width / samples.length;
    for (var i = 0; i < samples.length; i++) {
      final amplitude = samples[i].clamp(0.0, 1.0);
      final barHeight = (size.height * 0.45) * amplitude;
      final x = (i * step) + (step / 2);
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    if (oldDelegate.samples.length != samples.length) {
      return true;
    }
    for (var i = 0; i < samples.length; i++) {
      if (oldDelegate.samples[i] != samples[i]) {
        return true;
      }
    }
    return false;
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
