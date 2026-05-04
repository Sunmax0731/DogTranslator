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
  const LocalInferenceRuntimeConfigLoader({
    Map<String, String>? environment,
    this.currentDirectoryPath,
    this.executablePath,
  }) : _environment = environment;

  final Map<String, String>? _environment;
  final String? currentDirectoryPath;
  final String? executablePath;

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
    final environment = _environment ?? Platform.environment;
    final envConfig = environment['DOG_TRANSLATOR_RUNTIME_CONFIG'];
    if (envConfig != null && envConfig.isNotEmpty) {
      return <String>[
        envConfig,
        ..._candidatePathsFromDirs(_candidateDirectories(environment)),
      ];
    }

    return _candidatePathsFromDirs(_candidateDirectories(environment));
  }

  Set<String> _candidateDirectories(Map<String, String> environment) {
    final candidateDirs = <String>{
      currentDirectoryPath ?? Directory.current.path,
      File(executablePath ?? Platform.resolvedExecutable).parent.path,
    };

    final envRoot = environment['DOG_TRANSLATOR_RUNTIME_ROOT'];
    if (envRoot != null && envRoot.isNotEmpty) {
      candidateDirs.add(envRoot);
    }

    final localAppData = environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      candidateDirs.add('$localAppData${Platform.pathSeparator}DogTranslator');
      candidateDirs.add(
        '$localAppData${Platform.pathSeparator}DogTranslator${Platform.pathSeparator}.dog2vec',
      );
      candidateDirs.add(
        '$localAppData${Platform.pathSeparator}DogTranslator${Platform.pathSeparator}dog2vec-runtime',
      );
    }

    for (final root in candidateDirs.toList()) {
      candidateDirs.addAll(_ancestorDirectories(root, maxDepth: 8));
    }
    return candidateDirs;
  }

  List<String> _candidatePathsFromDirs(Set<String> candidateDirs) {
    final paths = <String>[];
    for (final dir in candidateDirs) {
      paths.add('$dir${Platform.pathSeparator}dog2vec_runtime.json');
      paths.add(
        '$dir${Platform.pathSeparator}.dog2vec${Platform.pathSeparator}dog2vec_runtime.json',
      );
    }
    return paths;
  }

  Iterable<String> _ancestorDirectories(
    String startPath, {
    int maxDepth = 8,
  }) sync* {
    var current = Directory(startPath).absolute;
    for (var depth = 0; depth < maxDepth; depth++) {
      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      yield parent.path;
      current = parent;
    }
  }
}
