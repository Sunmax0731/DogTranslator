# Dog2vec Integration Specification Task

## Forward Inference Stages
1. Record WAV audio.
2. Extract lightweight audio features.
3. Run dog-vocal detection gate.
4. Run active inference provider.
5. Produce:
   - emotion intent
   - vocal type
   - context
   - valence
   - arousal
   - confidence
   - message text

## Local Process Contract
- Invocation:
  - external command plus configured args
  - app appends `--input <wavPath>`
- Expected stdout JSON:
```json
{
  "detected": true,
  "vocal_type": "bark",
  "emotion": { "top": "alert", "score": 0.74 },
  "context": { "top": "stranger_or_noise", "score": 0.62 },
  "valence": -0.22,
  "arousal": 0.81,
  "confidence": 0.68,
  "message": "来客や物音に反応して警戒している可能性があります。"
}
```

## Fallback Rules
- If local runtime config is absent: use heuristic pipeline.
- If local process fails: use heuristic pipeline.
- If recording is too weak or likely non-dog: return uncertain result with quality guidance.
