# Gemma 3n Tokenizer Acquisition Notes

## Summary

This document details the official Google Gemma 3n SentencePiece tokenizer artifacts for use in the Vegolo app.

### Key Finding
- **Tokenizer file**: `tokenizer.model`
- **Size**: 4,696,020 bytes (~4.48 MB)
- **Format**: SentencePiece `.model` format
- **Shared across**: All Gemma 3n variants (E2B and E4B, both base and instruction-tuned)
- **LFS OID**: `ea5f0cc48abfbfc04d14562270a32e02149a3e7035f368cc5a462786f4a59961`

### Recommended Source
**Primary**: `google/gemma-3n-E4B-it` (instruction-tuned, 4B params)
- Repository: https://huggingface.co/google/gemma-3n-E4B-it
- Direct download URL: https://huggingface.co/google/gemma-3n-E4B-it/resolve/main/tokenizer.model
- Status: 🔒 Gated (requires accepting Gemma Terms of Use)
- Updated: October 30, 2025

**Alternative**: `google/gemma-3n-E2B-it` (instruction-tuned, 2B params)
- Repository: https://huggingface.co/google/gemma-3n-E2B-it
- Direct download URL: https://huggingface.co/google/gemma-3n-E2B-it/resolve/main/tokenizer.model
- Note: **Same tokenizer file** (identical LFS OID)

### Why E4B-it?
- Official instruction-tuned variant used in LiteRT-LM examples
- Most popular Gemma 3n variant (797 likes, 720K+ downloads)
- Same tokenizer is used across all Gemma 3n variants
- Referenced in official Google AI Edge documentation

## Repository Details

### Official Gemma 3n Repositories (Google)

| Repository | Type | Parameters | Downloads | Status |
|------------|------|------------|-----------|--------|
| google/gemma-3n-E4B-it | Transformers | 7.85B | 720K | Gated |
| google/gemma-3n-E2B-it | Transformers | 5.44B | 513K | Gated |
| google/gemma-3n-E4B-it-litert-lm | LiteRT-LM | 7.85B | 55K | Gated |
| google/gemma-3n-E2B-it-litert-lm | LiteRT-LM | 5.44B | 54K | Gated |

**Note**: LiteRT-LM repositories contain bundled `.litertlm` files (models + tokenizer embedded). For standalone tokenizer access, use the Transformers repositories.

## Tokenizer Files Available

From `google/gemma-3n-E4B-it` repository:

| File | Size | Format | Use Case |
|------|------|--------|----------|
| **tokenizer.model** | 4,696,020 bytes | SentencePiece | **Recommended** - Used by LiteRT-LM |
| tokenizer.json | 33,442,559 bytes | HF Tokenizers | Alternative (larger, faster in HF ecosystem) |
| tokenizer_config.json | 1,202,311 bytes | JSON | Configuration metadata |
| special_tokens_map.json | 769 bytes | JSON | Special token mappings |

**Recommendation**: Use `tokenizer.model` (SentencePiece format) as it's:
- Native format for Gemma models
- Smaller file size
- Directly compatible with TensorFlow Lite / LiteRT
- Referenced in official examples

## Licensing & Terms

### License Type
- **License**: `gemma` (Gemma Terms of Use)
- **License URL**: https://ai.google.dev/gemma/terms
- **Last Modified**: March 24, 2025

### Required Legal Notices

When redistributing the tokenizer in Vegolo, you **MUST** include:

```
Gemma is provided under and subject to the Gemma Terms of Use found at 
https://ai.google.dev/gemma/terms
```

### Key Documents

1. **Gemma Terms of Use**
   - URL: https://ai.google.dev/gemma/terms
   - Governs usage, distribution, and restrictions
   - Downloaded: `/tmp/gemma-terms.html`

2. **Gemma Prohibited Use Policy**
   - URL: https://ai.google.dev/gemma/prohibited_use_policy
   - Defines prohibited applications and use cases
   - Downloaded: `/tmp/gemma-prohibited.html`

### Distribution Requirements

For Vegolo app distribution:
- ✅ Include NOTICE text in app's legal notices/about screen
- ✅ Link to Terms of Use: https://ai.google.dev/gemma/terms
- ✅ Link to Prohibited Use Policy: https://ai.google.dev/gemma/prohibited_use_policy
- ✅ Only distribute tokenizer artifact (not model weights in this phase)
- ✅ Ensure compliance with prohibited use cases

## Authentication Barrier

### Issue Encountered
The Gemma 3n repositories are **gated** on Hugging Face. Access requires:

1. ✅ Hugging Face account
2. ⏳ Accept Gemma Terms of Use at: https://huggingface.co/google/gemma-3n-E4B-it
3. ⏳ Generate a Hugging Face access token with `read` permissions
4. ⏳ Configure token locally or use authenticated download

### How to Gain Access

**Option 1: Web Interface (Recommended)**
1. Visit https://huggingface.co/google/gemma-3n-E4B-it
2. Click "Accept terms" to review and accept Gemma Terms of Use
3. Once approved, download `tokenizer.model` via web interface or CLI

**Option 2: CLI with Authentication**
```bash
# Install Hugging Face CLI
pip install huggingface_hub

# Login (will prompt for token)
huggingface-cli login

# Download tokenizer
huggingface-cli download google/gemma-3n-E4B-it tokenizer.model \
  --local-dir /home/eriklinux/projects/vegolo/lib/core/ai/tokenizers \
  --local-dir-use-symlinks False

# Compute SHA-256
sha256sum /home/eriklinux/projects/vegolo/lib/core/ai/tokenizers/tokenizer.model

# Verify size
stat --format=%s /home/eriklinux/projects/vegolo/lib/core/ai/tokenizers/tokenizer.model
```

**Option 3: Python Script**
```python
from huggingface_hub import hf_hub_download
import hashlib

# Download with authentication
tokenizer_path = hf_hub_download(
    repo_id="google/gemma-3n-E4B-it",
    filename="tokenizer.model",
    local_dir="lib/core/ai/tokenizers",
    local_dir_use_symlinks=False
)

# Compute SHA-256
with open(tokenizer_path, 'rb') as f:
    sha256 = hashlib.sha256(f.read()).hexdigest()
    print(f"SHA-256: {sha256}")
```

## Verification Checklist

Once downloaded, verify the tokenizer:

- [ ] File size is exactly **4,696,020 bytes**
- [ ] SHA-256 checksum matches expected hash (compute after download)
- [ ] File format is SentencePiece (`.model` extension)
- [ ] LFS OID matches: `ea5f0cc48abfbfc04d14562270a32e02149a3e7035f368cc5a462786f4a59961`
- [ ] Place in `lib/core/ai/tokenizers/gemma-3n-tokenizer.model`
- [ ] Update `lib/core/ai/model_manifest.json` with SHA-256 and size
- [ ] Add legal notices to app

## Ambiguity Resolution

### Q: Are E2B and E4B tokenizers different?
**A**: No, they share the **identical tokenizer** (same LFS OID). Use either source.

### Q: Should we use tokenizer.model or tokenizer.json?
**A**: Use `tokenizer.model` (SentencePiece format):
- Smaller (4.7 MB vs 33.4 MB)
- Native format for TensorFlow Lite / LiteRT
- Matches official LiteRT-LM examples

### Q: Which variant for Vegolo?
**A**: Target both:
- **Nano/Low-RAM devices**: E2B variant (2B params)
- **Standard/Mid-RAM devices**: E4B variant (4B params)
- **Same tokenizer** works for both!

### Q: Transformers vs LiteRT-LM repos?
**A**: Use **Transformers repos** for standalone tokenizer access:
- LiteRT-LM repos only have bundled `.litertlm` files
- Transformers repos have separate tokenizer artifacts
- Same tokenizer is used in both

## Bonus: Reference Repository Information

As requested, here are the latest commits for documentation:

### google-ai-edge/LiteRT-LM
- **Latest commit**: `3fc75050...`
- **Date**: October 19, 2025, 06:41:35 UTC
- **Repository**: https://github.com/google-ai-edge/LiteRT-LM
- **Purpose**: Inference engine for LiteRT language models on Android/iOS

### google-ai-edge/gallery
- **Latest commit**: `fa69ff68...`
- **Date**: October 16, 2025, 23:04:36 UTC
- **Repository**: https://github.com/google-ai-edge/gallery
- **Purpose**: Reference Android apps using LiteRT-LM

## Next Steps

1. **Accept Gemma Terms**: Visit HF repo and accept terms
2. **Download tokenizer**: Use one of the methods above
3. **Compute SHA-256**: Update `manifest_patch.json`
4. **Update manifest**: Apply patch to `lib/core/ai/model_manifest.json`
5. **Add legal notices**: Include required text in app
6. **Test tokenizer**: Verify it loads correctly in LiteRT-LM pipeline

## Files Generated

This analysis produced:

1. ✅ `tokenizer_artifacts.json` - Detailed artifact metadata
2. ✅ `manifest_patch.json` - Ready-to-apply manifest patch (needs SHA-256)
3. ✅ `notes.md` - This comprehensive summary
4. 📥 `/tmp/gemma-terms.html` - Gemma Terms of Use (downloaded)
5. 📥 `/tmp/gemma-prohibited.html` - Prohibited Use Policy (downloaded)

## References

- Gemma 3n Model Card: https://huggingface.co/google/gemma-3n-E4B-it
- Gemma Terms: https://ai.google.dev/gemma/terms
- Prohibited Use: https://ai.google.dev/gemma/prohibited_use_policy
- LiteRT-LM: https://github.com/google-ai-edge/LiteRT-LM
- Gallery: https://github.com/google-ai-edge/gallery

