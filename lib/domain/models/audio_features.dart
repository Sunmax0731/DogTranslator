class AudioFeatures {
  const AudioFeatures({
    required this.durationSeconds,
    required this.rms,
    required this.peak,
    required this.zeroCrossingRate,
    required this.burstCount,
    required this.dynamicRange,
    required this.spectralCentroid,
    required this.highBandRatio,
    required this.crestFactor,
    required this.activityRatio,
    required this.pitchHz,
  });

  final double durationSeconds;
  final double rms;
  final double peak;
  final double zeroCrossingRate;
  final int burstCount;
  final double dynamicRange;
  final double spectralCentroid;
  final double highBandRatio;
  final double crestFactor;
  final double activityRatio;
  final double pitchHz;

  Map<String, dynamic> toJson() {
    return {
      'durationSeconds': durationSeconds,
      'rms': rms,
      'peak': peak,
      'zeroCrossingRate': zeroCrossingRate,
      'burstCount': burstCount,
      'dynamicRange': dynamicRange,
      'spectralCentroid': spectralCentroid,
      'highBandRatio': highBandRatio,
      'crestFactor': crestFactor,
      'activityRatio': activityRatio,
      'pitchHz': pitchHz,
    };
  }

  factory AudioFeatures.fromJson(Map<String, dynamic> json) {
    return AudioFeatures(
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0,
      rms: (json['rms'] as num?)?.toDouble() ?? 0,
      peak: (json['peak'] as num?)?.toDouble() ?? 0,
      zeroCrossingRate: (json['zeroCrossingRate'] as num?)?.toDouble() ?? 0,
      burstCount: (json['burstCount'] as num?)?.toInt() ?? 0,
      dynamicRange: (json['dynamicRange'] as num?)?.toDouble() ?? 0,
      spectralCentroid: (json['spectralCentroid'] as num?)?.toDouble() ?? 0,
      highBandRatio: (json['highBandRatio'] as num?)?.toDouble() ?? 0,
      crestFactor: (json['crestFactor'] as num?)?.toDouble() ?? 0,
      activityRatio: (json['activityRatio'] as num?)?.toDouble() ?? 0,
      pitchHz: (json['pitchHz'] as num?)?.toDouble() ?? 0,
    );
  }
}
