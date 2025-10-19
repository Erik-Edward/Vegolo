#!/bin/bash
#
# Download and verify Gemma 3n tokenizer
# 
# Prerequisites:
# 1. Accept Gemma Terms at: https://huggingface.co/google/gemma-3n-E4B-it
# 2. Install: pip install huggingface_hub
# 3. Login: huggingface-cli login
#

set -e

REPO="google/gemma-3n-E4B-it"
FILENAME="tokenizer.model"
TARGET_DIR="lib/core/ai/tokenizers"
TARGET_FILE="$TARGET_DIR/gemma-3n-tokenizer.model"
EXPECTED_SIZE=4696020
EXPECTED_LFS_OID="ea5f0cc48abfbfc04d14562270a32e02149a3e7035f368cc5a462786f4a59961"

echo "========================================="
echo "Gemma 3n Tokenizer Download & Verification"
echo "========================================="
echo ""

# Check if huggingface-cli is available
if ! command -v huggingface-cli &> /dev/null; then
    echo "❌ huggingface-cli not found"
    echo ""
    echo "Install with:"
    echo "  pip install huggingface_hub"
    echo ""
    exit 1
fi

echo "✅ huggingface-cli found"
echo ""

# Check authentication
if ! huggingface-cli whoami &> /dev/null; then
    echo "❌ Not authenticated with Hugging Face"
    echo ""
    echo "Login with:"
    echo "  huggingface-cli login"
    echo ""
    echo "Then accept Gemma Terms at:"
    echo "  https://huggingface.co/google/gemma-3n-E4B-it"
    echo ""
    exit 1
fi

USER=$(huggingface-cli whoami | head -1)
echo "✅ Authenticated as: $USER"
echo ""

# Create target directory
mkdir -p "$TARGET_DIR"
echo "📁 Target directory: $TARGET_DIR"
echo ""

# Download tokenizer
echo "📥 Downloading tokenizer from $REPO..."
echo ""

huggingface-cli download \
    "$REPO" \
    "$FILENAME" \
    --local-dir "$TARGET_DIR" \
    --local-dir-use-symlinks False

# Move to final location if needed
if [ -f "$TARGET_DIR/$FILENAME" ] && [ "$TARGET_DIR/$FILENAME" != "$TARGET_FILE" ]; then
    mv "$TARGET_DIR/$FILENAME" "$TARGET_FILE"
fi

echo ""
echo "✅ Downloaded successfully"
echo ""

# Verify file exists
if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ File not found at $TARGET_FILE"
    exit 1
fi

# Check file size
ACTUAL_SIZE=$(stat --format=%s "$TARGET_FILE" 2>/dev/null || stat -f%z "$TARGET_FILE" 2>/dev/null)
echo "📊 Verifying file..."
echo "  Expected size: $EXPECTED_SIZE bytes"
echo "  Actual size:   $ACTUAL_SIZE bytes"

if [ "$ACTUAL_SIZE" -ne "$EXPECTED_SIZE" ]; then
    echo "  ⚠️  Size mismatch!"
    echo ""
else
    echo "  ✅ Size verified"
    echo ""
fi

# Compute SHA-256
echo "🔐 Computing SHA-256 checksum..."
if command -v sha256sum &> /dev/null; then
    SHA256=$(sha256sum "$TARGET_FILE" | awk '{print $1}')
elif command -v shasum &> /dev/null; then
    SHA256=$(shasum -a 256 "$TARGET_FILE" | awk '{print $1}')
else
    echo "  ⚠️  No SHA-256 tool found (sha256sum or shasum)"
    SHA256="UNABLE_TO_COMPUTE"
fi

echo "  SHA-256: $SHA256"
echo ""

# Update manifest template
echo "📝 Updating manifest_patch.json..."

if [ -f "manifest_patch.json" ]; then
    # Use sed to replace the placeholder
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/COMPUTE_AFTER_DOWNLOAD/$SHA256/g" manifest_patch.json
    else
        sed -i "s/COMPUTE_AFTER_DOWNLOAD/$SHA256/g" manifest_patch.json
    fi
    echo "  ✅ Updated manifest_patch.json with SHA-256"
else
    echo "  ⚠️  manifest_patch.json not found"
fi

echo ""

# Summary
echo "========================================="
echo "✅ DOWNLOAD COMPLETE"
echo "========================================="
echo ""
echo "Tokenizer location: $TARGET_FILE"
echo "File size:          $ACTUAL_SIZE bytes"
echo "SHA-256:            $SHA256"
echo ""
echo "Next steps:"
echo "1. Review manifest_patch.json"
echo "2. Apply changes to lib/core/ai/model_manifest.json"
echo "3. Test tokenizer loading in your app"
echo "4. Add legal notices (see notes.md)"
echo ""
echo "Legal requirement:"
echo "  Include in app: 'Gemma is provided under and subject to the"
echo "  Gemma Terms of Use found at https://ai.google.dev/gemma/terms'"
echo ""

