# Gemma 3n Tokenizer Integration Guide

This directory contains artifacts and documentation for integrating the official Google Gemma 3n SentencePiece tokenizer into the Vegolo app.

## 📦 Generated Files

| File | Purpose | Status |
|------|---------|--------|
| `tokenizer_artifacts.json` | Detailed artifact metadata and download URLs | ✅ Complete |
| `manifest_patch.json` | Ready-to-apply patch for model manifest | ⏳ Needs SHA-256 |
| `notes.md` | Comprehensive analysis and recommendations | ✅ Complete |
| `GEMMA_LEGAL_NOTICES.txt` | Legal notices for app distribution | ✅ Complete |
| `download_tokenizer.sh` | Bash script to download & verify tokenizer | ✅ Ready to use |
| `download_tokenizer.py` | Python script to download & verify tokenizer | ✅ Ready to use |
| `TOKENIZER_README.md` | This file | ✅ Complete |

## 🚀 Quick Start

### Step 1: Accept Gemma Terms

Visit the Hugging Face repository and accept the terms:

👉 **https://huggingface.co/google/gemma-3n-E4B-it**

Click "Agree and access repository" after reviewing the terms.

### Step 2: Authenticate

Choose one of these methods:

**Option A: Hugging Face CLI**
```bash
pip install huggingface_hub
huggingface-cli login
```

**Option B: Python API with token**
```bash
export HF_TOKEN="your_token_here"
```

### Step 3: Download Tokenizer

Choose your preferred method:

**Bash Script (Recommended)**
```bash
./download_tokenizer.sh
```

**Python Script**
```bash
python3 download_tokenizer.py
```

**Manual Download**
```bash
pip install huggingface_hub
huggingface-cli download google/gemma-3n-E4B-it tokenizer.model \
  --local-dir lib/core/ai/tokenizers \
  --local-dir-use-symlinks False

# Compute SHA-256
sha256sum lib/core/ai/tokenizers/tokenizer.model
```

### Step 4: Verify

The download script will automatically:
- ✅ Download tokenizer.model (4,696,020 bytes)
- ✅ Verify file size
- ✅ Compute SHA-256 checksum
- ✅ Update manifest_patch.json with checksum
- ✅ Place file in `lib/core/ai/tokenizers/`

### Step 5: Update Manifest

Apply the patch to your model manifest:

```bash
# Review the patch
cat manifest_patch.json

# Manually merge the tokenizer entries into:
# lib/core/ai/model_manifest.json
```

### Step 6: Add Legal Notices

Add the required legal notice to your app:

```
Gemma is provided under and subject to the Gemma Terms of Use 
found at https://ai.google.dev/gemma/terms
```

See `GEMMA_LEGAL_NOTICES.txt` for the complete notice template.

## 📋 Key Information

### Tokenizer Details
- **File**: `tokenizer.model`
- **Size**: 4,696,020 bytes (~4.48 MB)
- **Format**: SentencePiece
- **Source**: `google/gemma-3n-E4B-it` on Hugging Face
- **License**: Gemma Terms of Use
- **Shared**: Same tokenizer for E2B and E4B variants

### Why E4B-it?
- Official instruction-tuned variant
- Most widely used (720K+ downloads)
- Referenced in LiteRT-LM documentation
- Same tokenizer as all other Gemma 3n variants

### Repository Status
- 🔒 **Gated**: Requires accepting Gemma Terms of Use
- 🔐 **Authentication**: Required for download
- ✅ **Official**: Maintained by Google DeepMind

## 📖 Detailed Documentation

For comprehensive information, see:

- **`notes.md`** - Full analysis, repository details, licensing, verification checklist
- **`tokenizer_artifacts.json`** - Technical metadata, LFS OIDs, alternative formats
- **`manifest_patch.json`** - Manifest integration guide with instructions
- **`GEMMA_LEGAL_NOTICES.txt`** - Complete legal notice template

## 🔐 Licensing

### Terms of Use
- **License**: Gemma Terms of Use
- **URL**: https://ai.google.dev/gemma/terms
- **Last Modified**: March 24, 2025

### Prohibited Use Policy
- **URL**: https://ai.google.dev/gemma/prohibited_use_policy
- **Key Restrictions**: No illegal activity, no harm, no deception

### Required Notice
When distributing Vegolo with the Gemma tokenizer, you **MUST** include:

```
Gemma is provided under and subject to the Gemma Terms of Use 
found at https://ai.google.dev/gemma/terms
```

This notice should appear in:
- App's "About" or "Legal" screen
- App store descriptions (recommended)
- Documentation
- Any promotional materials that mention Gemma

## 🧪 Verification Checklist

Before integrating into production:

- [ ] Tokenizer downloaded from official Google repository
- [ ] File size verified: **4,696,020 bytes** exactly
- [ ] SHA-256 checksum computed and recorded
- [ ] File placed in `lib/core/ai/tokenizers/gemma-3n-tokenizer.model`
- [ ] `lib/core/ai/model_manifest.json` updated with SHA-256 and size
- [ ] Legal notices added to app
- [ ] Tokenizer loads successfully in LiteRT-LM
- [ ] Terms of Use accepted on Hugging Face
- [ ] Prohibited Use Policy reviewed and understood

## 🔗 Official Resources

| Resource | URL |
|----------|-----|
| Gemma 3n E4B-it | https://huggingface.co/google/gemma-3n-E4B-it |
| Gemma 3n E2B-it | https://huggingface.co/google/gemma-3n-E2B-it |
| Gemma Terms | https://ai.google.dev/gemma/terms |
| Prohibited Use | https://ai.google.dev/gemma/prohibited_use_policy |
| LiteRT-LM | https://github.com/google-ai-edge/LiteRT-LM |
| Gallery | https://github.com/google-ai-edge/gallery |

## 🎯 Integration in Vegolo

### Model Manifest Structure

Update `lib/core/ai/model_manifest.json`:

```json
{
  "variants": [
    {
      "name": "nano",
      "displayName": "Gemma 3n Nano (2B)",
      "files": [
        {
          "type": "tokenizer",
          "path": "tokenizers/gemma-3n-tokenizer.model",
          "sha256": "<COMPUTED_SHA256>",
          "size_bytes": 4696020
        }
      ]
    }
  ]
}
```

### Usage in Code

```dart
// Example: Loading tokenizer in Gemma service
final tokenizerPath = await _modelManager.getAssetPath(
  'tokenizers/gemma-3n-tokenizer.model'
);

// Verify checksum before use (recommended)
final verified = await _modelManager.verifyChecksum(
  tokenizerPath,
  expectedSha256: manifest.files[0].sha256,
);

if (!verified) {
  throw TokenizerVerificationException('Checksum mismatch');
}
```

## 🐛 Troubleshooting

### Error: "Access to model google/gemma-3n-E4B-it is restricted"
**Solution**: Accept Gemma Terms at https://huggingface.co/google/gemma-3n-E4B-it

### Error: "Not authenticated with Hugging Face"
**Solution**: Run `huggingface-cli login` or set `HF_TOKEN` environment variable

### Error: "File size mismatch"
**Solution**: 
1. Delete partial download
2. Check network connection
3. Retry download
4. Verify LFS is properly handled

### Error: "huggingface-cli not found"
**Solution**: Install with `pip install huggingface_hub`

## 📞 Support

### Gemma-Related Questions
- Gemma documentation: https://ai.google.dev/gemma
- Hugging Face support: https://discuss.huggingface.co/

### Vegolo-Specific Questions
- Project documentation: See `/docs` directory
- Issues: GitHub Issues (when available)

## 🎉 Success Indicators

You've successfully integrated the tokenizer when:

1. ✅ Tokenizer file exists at `lib/core/ai/tokenizers/gemma-3n-tokenizer.model`
2. ✅ SHA-256 matches in `model_manifest.json`
3. ✅ File size is exactly 4,696,020 bytes
4. ✅ Legal notices included in app
5. ✅ Tokenizer loads without errors
6. ✅ Sample text tokenizes correctly

## 📅 Maintenance

### Updating the Tokenizer

The Gemma 3n tokenizer is stable and unlikely to change. However, if an update is released:

1. Check the model card for changelog
2. Download new version
3. Compute new SHA-256
4. Update manifest
5. Test thoroughly before deploying
6. Update this documentation

### Monitoring

Keep track of:
- Gemma model updates: Watch Hugging Face repositories
- License changes: Monitor https://ai.google.dev/gemma/terms
- LiteRT-LM updates: Watch https://github.com/google-ai-edge/LiteRT-LM

---

**Generated**: October 19, 2025
**Last Updated**: October 19, 2025
**Status**: Ready for authentication and download

