# Dog Voice Local Runtime

This folder hosts a local Python inference runtime for DogTranslator.

## Modes
- Bootstrap mode: runs handcrafted inference from WAV even when Dog2vec weights are not installed.
- Dog2vec-enhanced mode: if `models/dog2vec/dog2vec_130k_9.pt` exists and the Python dependencies are installed, the runtime loads Dog2vec and extracts embeddings before producing the final JSON response.

## Expected entrypoint
- `python app/infer.py --input <wav-path>`

## Bootstrap steps
1. Install Python packages from `requirements.txt`
2. Run `tools/bootstrap_runtime.ps1` to clone the upstream Dog2vec repo helper code and optionally download the weight file.
3. Copy or rename `dog2vec_runtime.example.json` to `dog2vec_runtime.json` at the repo root if needed.

## Current limitation
- This runtime can execute without the Dog2vec weight file, but in that case the output is still heuristic-first.
- The upstream Dog2vec base model is available, but task-specific classifier heads are not bundled in this repository.
