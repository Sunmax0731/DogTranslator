import 'dart:convert';
import 'dart:io';

class LocalInferenceRuntimeConfig {
  const LocalInferenceRuntimeConfig({
    required this.enabled,
    required this.command,
    required this.arguments,
    required this.timeout,
    this.workingDirectory,
  });

  final bool enabled;
  final String command;
  final List<String> arguments;
  final Duration timeout;
  final String? workingDirectory;

  factory LocalInferenceRuntimeConfig.fromJson(Map<String, dynamic> json) {
    return LocalInferenceRuntimeConfig(
      enabled: json['enabled'] as bool? ?? false,
      command: json['command'] as String? ?? '',
      arguments: (json['args'] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .toList(growable: false),
      timeout: Duration(
        milliseconds: (json['timeoutMs'] as num?)?.toInt() ?? 10000,
      ),
      workingDirectory: json['workingDirectory'] as String?,
    );
  }
}

class LocalInferenceRuntimeConfigLoader {
  const LocalInferenceRuntimeConfigLoader();

  Future<LocalInferenceRuntimeConfig?> load() async {
    for (final path in _candidatePaths()) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final config = LocalInferenceRuntimeConfig.fromJson(json);
      if (config.command.isNotEmpty && config.enabled) {
        return config;
      }
    }
    return null;
  }

  List<String> _candidatePaths() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return <String>[
      '${Directory.current.path}${Platform.pathSeparator}dog2vec_runtime.json',
      '$exeDir${Platform.pathSeparator}dog2vec_runtime.json',
      '${Directory.current.path}${Platform.pathSeparator}.dog2vec${Platform.pathSeparator}dog2vec_runtime.json',
    ];
  }
}
