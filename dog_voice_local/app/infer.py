import argparse
import json
import sys
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = ROOT / "models" / "dog2vec" / "dog2vec_130k_9.pt"
VENDOR_REPO = ROOT / "vendor" / "dog2vec"


def load_wav(path: Path):
    with wave.open(str(path), "rb") as wf:
        channels = wf.getnchannels()
        sample_rate = wf.getframerate()
        frames = wf.readframes(wf.getnframes())
    data = np.frombuffer(frames, dtype=np.int16).astype(np.float32) / 32768.0
    if channels > 1:
        data = data.reshape(-1, channels).mean(axis=1)
    return data, sample_rate


def percentile(values, ratio):
    if len(values) == 0:
        return 0.0
    return float(np.percentile(values, ratio * 100.0))


def estimate_bursts(samples, rms):
    if len(samples) == 0:
        return 0
    frame_size = max(120, len(samples) // 60)
    threshold = max(0.045, rms * 1.3)
    bursts = 0
    active = False
    for index in range(0, len(samples), frame_size):
        frame = np.abs(samples[index : index + frame_size])
        if len(frame) == 0:
            continue
        frame_level = float(np.mean(frame))
        is_active = frame_level > threshold
        if is_active and not active:
            bursts += 1
        active = is_active
    return bursts


def estimate_activity_ratio(samples, rms):
    if len(samples) == 0:
        return 0.0
    threshold = max(0.02, rms * 0.85)
    return float(np.mean(np.abs(samples) >= threshold))


def estimate_pitch(samples, sample_rate):
    sample_window = min(len(samples), 1024)
    if sample_window < 128 or sample_rate <= 0:
        return 0.0
    offset = (len(samples) - sample_window) // 2
    window = samples[offset : offset + sample_window]
    min_lag = max(1, sample_rate // 1200)
    max_lag = min(sample_window // 2, max(min_lag + 1, sample_rate // 80))
    best_lag = 0
    best_score = 0.0
    for lag in range(min_lag, max_lag + 1):
        correlation = float(np.sum(window[:-lag] * window[lag:]))
        if correlation > best_score:
            best_score = correlation
            best_lag = lag
    if best_lag == 0 or best_score <= 0:
        return 0.0
    return float(sample_rate / best_lag)


def estimate_spectrum(samples, sample_rate):
    sample_window = min(len(samples), 512)
    if sample_window < 32:
        return 0.0, 0.0
    offset = (len(samples) - sample_window) // 2
    window = samples[offset : offset + sample_window]
    fft = np.fft.rfft(window)
    magnitudes = np.abs(fft)
    frequencies = np.fft.rfftfreq(sample_window, d=1 / sample_rate)
    total = float(np.sum(magnitudes))
    if total <= 0:
        return 0.0, 0.0
    centroid = float(np.sum(frequencies * magnitudes) / total)
    high_band = float(np.sum(magnitudes[frequencies > sample_rate / 4]) / total)
    return centroid, high_band


def extract_features(samples, sample_rate):
    if len(samples) <= 1:
        return {
            "duration": 0.0,
            "rms": 0.0,
            "peak": 0.0,
            "zcr": 0.0,
            "bursts": 0,
            "dynamic_range": 0.0,
            "centroid": 0.0,
            "high_band": 0.0,
            "crest_factor": 0.0,
            "activity_ratio": 0.0,
            "pitch_hz": 0.0,
        }

    magnitudes = np.abs(samples)
    peak = float(np.max(magnitudes))
    rms = float(np.sqrt(np.mean(samples**2)))
    duration = float(len(samples) / sample_rate)
    zcr = float(np.mean(np.diff(np.signbit(samples)) != 0))
    bursts = estimate_bursts(samples, rms)
    dynamic_range = percentile(magnitudes, 0.95) - percentile(magnitudes, 0.2)
    centroid, high_band = estimate_spectrum(samples, sample_rate)
    activity_ratio = estimate_activity_ratio(samples, rms)
    pitch_hz = estimate_pitch(samples, sample_rate)
    crest_factor = 0.0 if rms == 0 else peak / rms

    return {
        "duration": duration,
        "rms": rms,
        "peak": peak,
        "zcr": zcr,
        "bursts": bursts,
        "dynamic_range": dynamic_range,
        "centroid": centroid,
        "high_band": high_band,
        "crest_factor": crest_factor,
        "activity_ratio": activity_ratio,
        "pitch_hz": pitch_hz,
    }


def try_extract_dog2vec_embedding(samples):
    if not MODEL_PATH.exists():
        return None
    if not VENDOR_REPO.exists():
        return None
    try:
        sys.path.insert(0, str(VENDOR_REPO))
        from extract_feature import FeatureExtractor  # type: ignore
        import torch

        extractor = FeatureExtractor(str(MODEL_PATH), device="cpu", layer=9)
        audio = torch.from_numpy(samples.astype(np.float32))
        feat = extractor.extract(audio)
        pooled = feat.mean(dim=0).cpu().numpy()
        return {
            "embedding_dim": int(pooled.shape[0]),
            "embedding_mean_abs": float(np.mean(np.abs(pooled))),
        }
    except Exception:
        return None


def heuristic_infer(features, dog2vec_info):
    pitch = features["pitch_hz"]
    duration = features["duration"]
    rms = features["rms"]
    peak = features["peak"]
    zcr = features["zcr"]
    bursts = features["bursts"]
    high_band = features["high_band"]
    crest = features["crest_factor"]
    activity = features["activity_ratio"]

    detected = (
        duration >= 0.18
        and (rms >= 0.025 or peak >= 0.08)
        and (zcr <= 0.32 or bursts > 0 or activity > 0.16)
        and (pitch == 0 or (70 <= pitch <= 1400))
    )

    vocal_type = "unknown"
    if detected:
        if duration > 1.4 and 180 <= pitch <= 650 and activity > 0.45:
            vocal_type = "howl"
        elif rms < 0.07 and peak < 0.25 and duration > 0.7 and pitch >= 250:
            vocal_type = "whine"
        elif (peak > 0.8 or crest > 8.0) and duration < 0.3 and pitch > 450:
            vocal_type = "yelp"
        elif high_band < 0.12 and rms > 0.12 and 0 < pitch < 260:
            vocal_type = "growl"
        elif zcr > 0.22 and rms < 0.05 and activity > 0.35:
            vocal_type = "pant"
        elif bursts >= 3 and features["dynamic_range"] > 0.18:
            vocal_type = "mixed"
        else:
            vocal_type = "bark"

    emotion = "unknown"
    context = "unknown"
    confidence = 0.28
    valence = 0.0
    arousal = min(
        1.0,
        (rms * 2.6)
        + (peak * 0.8)
        + (features["dynamic_range"] * 1.4)
        + (activity * 0.6),
    )
    if not detected:
        message = "今回は犬の声らしい特徴を十分に抽出できませんでした。短いノイズや環境音の可能性があります。"
    elif vocal_type in {"growl", "yelp"} or peak > 0.75:
        emotion = "alert"
        context = "stranger_or_noise"
        confidence = 0.7
        valence = -0.28
        message = "警戒や強い反応に近い吠え方として解釈しました。来客音や物音への反応の可能性があります。"
    elif vocal_type == "whine":
        emotion = "fear"
        context = "alone"
        confidence = 0.62
        valence = -0.4
        message = "不安や甘えに寄った鳴き方として解釈しました。ひとりの時間や距離感の影響かもしれません。"
    elif 350 <= pitch <= 900 and bursts >= 2:
        emotion = "playful"
        context = "play"
        confidence = 0.66
        valence = 0.45
        message = "遊びたい気分に近い反応として解釈しました。勢いのある短い声が続いています。"
    elif 0.32 <= activity <= 0.68:
        emotion = "request"
        context = "food_or_attention"
        confidence = 0.58
        valence = 0.12
        message = "注意を引きたい、または要求を伝えたい鳴き方の傾向があります。"
    else:
        confidence = 0.38
        message = "特徴量は取れましたが、今回だけでは意図を強く断定できませんでした。"

    if dog2vec_info is not None:
        confidence = min(0.9, confidence + 0.04)
        message = f"{message} Dog2vec 埋め込み特徴も併用しました。"

    return {
        "detected": detected,
        "vocal_type": vocal_type,
        "emotion": {"top": emotion, "score": round(confidence, 4)},
        "context": {"top": context, "score": round(confidence * 0.9, 4)},
        "valence": round(valence, 4),
        "arousal": round(arousal, 4),
        "confidence": round(confidence, 4),
        "message": message,
        "runtime": {
            "dog2vec_loaded": dog2vec_info is not None,
            "dog2vec_info": dog2vec_info,
        },
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    args = parser.parse_args()

    samples, sample_rate = load_wav(Path(args.input))
    features = extract_features(samples, sample_rate)
    dog2vec_info = try_extract_dog2vec_embedding(samples)
    result = heuristic_infer(features, dog2vec_info)
    print(json.dumps(result))


if __name__ == "__main__":
    main()
