#!/usr/bin/env python3
"""
Download and verify Gemma 3n tokenizer

Prerequisites:
1. Accept Gemma Terms at: https://huggingface.co/google/gemma-3n-E4B-it
2. Install: pip install huggingface_hub
3. Login: huggingface-cli login (or set HF_TOKEN environment variable)
"""

import hashlib
import json
import os
import sys
from pathlib import Path

try:
    from huggingface_hub import hf_hub_download, whoami
except ImportError:
    print("❌ huggingface_hub not installed")
    print("\nInstall with:")
    print("  pip install huggingface_hub")
    sys.exit(1)

# Configuration
REPO_ID = "google/gemma-3n-E4B-it"
FILENAME = "tokenizer.model"
TARGET_DIR = Path("lib/core/ai/tokenizers")
TARGET_FILENAME = "gemma-3n-tokenizer.model"
EXPECTED_SIZE = 4696020
EXPECTED_LFS_OID = "ea5f0cc48abfbfc04d14562270a32e02149a3e7035f368cc5a462786f4a59961"


def compute_sha256(file_path: Path) -> str:
    """Compute SHA-256 hash of a file."""
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def update_manifest_patch(sha256: str):
    """Update manifest_patch.json with the computed SHA-256."""
    manifest_path = Path("manifest_patch.json")
    if not manifest_path.exists():
        print("  ⚠️  manifest_patch.json not found")
        return
    
    try:
        with open(manifest_path, 'r') as f:
            content = f.read()
        
        updated_content = content.replace("COMPUTE_AFTER_DOWNLOAD", sha256)
        
        with open(manifest_path, 'w') as f:
            f.write(updated_content)
        
        print(f"  ✅ Updated manifest_patch.json with SHA-256")
    except Exception as e:
        print(f"  ⚠️  Failed to update manifest_patch.json: {e}")


def main():
    print("=" * 50)
    print("Gemma 3n Tokenizer Download & Verification")
    print("=" * 50)
    print()
    
    # Check authentication
    try:
        user_info = whoami()
        username = user_info.get("name", "unknown")
        print(f"✅ Authenticated as: {username}")
        print()
    except Exception as e:
        print("❌ Not authenticated with Hugging Face")
        print()
        print("Login with:")
        print("  huggingface-cli login")
        print()
        print("Or set HF_TOKEN environment variable")
        print()
        print("Then accept Gemma Terms at:")
        print(f"  https://huggingface.co/{REPO_ID}")
        print()
        sys.exit(1)
    
    # Create target directory
    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    print(f"📁 Target directory: {TARGET_DIR}")
    print()
    
    # Download tokenizer
    print(f"📥 Downloading tokenizer from {REPO_ID}...")
    print()
    
    try:
        downloaded_path = hf_hub_download(
            repo_id=REPO_ID,
            filename=FILENAME,
            local_dir=TARGET_DIR,
            local_dir_use_symlinks=False
        )
        print()
        print("✅ Downloaded successfully")
        print()
    except Exception as e:
        print()
        print(f"❌ Download failed: {e}")
        print()
        print("Make sure you have:")
        print("1. Accepted Gemma Terms at:")
        print(f"   https://huggingface.co/{REPO_ID}")
        print("2. Valid authentication (huggingface-cli login)")
        sys.exit(1)
    
    # Move to final location with target filename
    source_path = Path(downloaded_path)
    target_path = TARGET_DIR / TARGET_FILENAME
    
    if source_path != target_path:
        if target_path.exists():
            target_path.unlink()
        source_path.rename(target_path)
    
    # Verify file exists
    if not target_path.exists():
        print(f"❌ File not found at {target_path}")
        sys.exit(1)
    
    # Check file size
    actual_size = target_path.stat().st_size
    print("📊 Verifying file...")
    print(f"  Expected size: {EXPECTED_SIZE:,} bytes")
    print(f"  Actual size:   {actual_size:,} bytes")
    
    if actual_size == EXPECTED_SIZE:
        print("  ✅ Size verified")
    else:
        print("  ⚠️  Size mismatch!")
    print()
    
    # Compute SHA-256
    print("🔐 Computing SHA-256 checksum...")
    sha256 = compute_sha256(target_path)
    print(f"  SHA-256: {sha256}")
    print()
    
    # Update manifest
    print("📝 Updating manifest_patch.json...")
    update_manifest_patch(sha256)
    print()
    
    # Summary
    print("=" * 50)
    print("✅ DOWNLOAD COMPLETE")
    print("=" * 50)
    print()
    print(f"Tokenizer location: {target_path}")
    print(f"File size:          {actual_size:,} bytes")
    print(f"SHA-256:            {sha256}")
    print()
    print("Next steps:")
    print("1. Review manifest_patch.json")
    print("2. Apply changes to lib/core/ai/model_manifest.json")
    print("3. Test tokenizer loading in your app")
    print("4. Add legal notices (see GEMMA_LEGAL_NOTICES.txt)")
    print()
    print("Legal requirement:")
    print("  Include in app: 'Gemma is provided under and subject to the")
    print("  Gemma Terms of Use found at https://ai.google.dev/gemma/terms'")
    print()


if __name__ == "__main__":
    main()

