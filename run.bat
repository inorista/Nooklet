./scripts/download_models.sh multilingual 2240

python3 scripts/inspect_model.py Models/multilingual/2240ms --out Nooklet/Services/ASR/ModelSignatures.json

xcodegen generate
