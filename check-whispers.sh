#!/bin/bash

echo "=========================================="
echo "  COMPREHENSIVE 404 DIAGNOSTIC"
echo "=========================================="
echo ""

# 1. Check current directory
echo "1. Current directory:"
pwd
echo ""

# 2. Check _config.yml exists
if [ ! -f "_config.yml" ]; then
    echo "❌ ERROR: Not in Jekyll root directory!"
    exit 1
fi

# 3. Check collections configuration
echo "2. Collections configuration in _config.yml:"
echo "---"
grep -A 10 "collections:" _config.yml || echo "❌ NO COLLECTIONS FOUND"
echo ""

# 4. Check exclude configuration
echo "3. Exclude configuration in _config.yml:"
echo "---"
grep -A 15 "exclude:" _config.yml || echo "No exclude section"
echo ""
if grep -q "whispersThroughMe" _config.yml; then
    echo "⚠️  WARNING: 'whispersThroughMe' found in _config.yml - checking if it's excluded..."
    if grep "exclude:" _config.yml -A 20 | grep -q "whispersThroughMe"; then
        echo "❌ PROBLEM FOUND: whispersThroughMe IS in exclude list!"
        echo "This prevents Jekyll from building it."
    fi
fi
echo ""

# 5. Check folder structure
echo "4. Folder structure:"
echo "---"
echo "_whispersThroughMe folder:"
if [ -d "_whispersThroughMe" ]; then
    echo "✓ EXISTS"
    ls -la _whispersThroughMe/
else
    echo "❌ MISSING"
fi
echo ""

echo "whispersThroughMe folder:"
if [ -d "whispersThroughMe" ]; then
    echo "✓ EXISTS"
    ls -la whispersThroughMe/
else
    echo "❌ MISSING"
fi
echo ""

# 6. Check post format
echo "5. Checking first post format:"
echo "---"
if [ -f "_whispersThroughMe/firstDraft.md" ]; then
    echo "First 15 lines of firstDraft.md:"
    head -15 _whispersThroughMe/firstDraft.md
else
    echo "❌ firstDraft.md not found"
    echo "Available files:"
    ls -la _whispersThroughMe/ 2>/dev/null || echo "No files"
fi
echo ""

# 7. Check if whisper layout exists
echo "6. Checking for whisper layout:"
echo "---"
if [ -f "_layouts/whisper.html" ]; then
    echo "✓ _layouts/whisper.html EXISTS"
else
    echo "❌ _layouts/whisper.html MISSING"
fi
echo ""

# 8. Do a fresh build
echo "7. Testing fresh build:"
echo "---"
echo "Cleaning old build..."
rm -rf _site
echo "Building with verbose output..."
JEKYLL_ENV=development bundle exec jekyll build --verbose 2>&1 | tee build-output.txt
echo ""

# 9. Check _site output
echo "8. Checking _site directory after build:"
echo "---"
if [ -d "_site" ]; then
    echo "✓ _site exists"
    echo ""
    echo "_site contents:"
    ls -la _site/ | head -20
    echo ""
    
    if [ -d "_site/whispersThroughMe" ]; then
        echo "✓✓✓ SUCCESS: whispersThroughMe EXISTS in _site!"
        echo "Contents:"
        ls -la _site/whispersThroughMe/
    else
        echo "❌❌❌ PROBLEM: whispersThroughMe NOT in _site"
        echo "This is why you get 404!"
    fi
else
    echo "❌ _site directory not created"
fi
echo ""

# 10. Check what Jekyll saw
echo "9. What Jekyll processed:"
echo "---"
echo "Searching build output for 'whisper':"
grep -i whisper build-output.txt || echo "No mention of whispers in build"
echo ""

# 11. Summary
echo "=========================================="
echo "  DIAGNOSTIC SUMMARY"
echo "=========================================="
echo ""

HAS_COLLECTION=false
HAS_FOLDER=false
HAS_INDEX=false
HAS_LAYOUT=false
IN_SITE=false
IS_EXCLUDED=false

grep -q "whispersThroughMe:" _config.yml && HAS_COLLECTION=true
[ -d "_whispersThroughMe" ] && HAS_FOLDER=true
[ -f "whispersThroughMe/index.html" ] && HAS_INDEX=true
[ -f "_layouts/whisper.html" ] && HAS_LAYOUT=true
[ -d "_site/whispersThroughMe" ] && IN_SITE=true
grep "exclude:" _config.yml -A 20 | grep -q "whispersThroughMe" && IS_EXCLUDED=true

echo "Collection configured: $HAS_COLLECTION"
echo "Folder exists: $HAS_FOLDER"
echo "Index exists: $HAS_INDEX"
echo "Layout exists: $HAS_LAYOUT"
echo "Built to _site: $IN_SITE"
echo "Is excluded: $IS_EXCLUDED"
echo ""

if [ "$IS_EXCLUDED" = true ]; then
    echo "🔴 MAIN PROBLEM: whispersThroughMe is in the exclude list!"
    echo "   Fix: Remove it from exclude in _config.yml"
elif [ "$IN_SITE" = false ]; then
    echo "🔴 MAIN PROBLEM: Collection not building to _site"
    echo "   Possible causes:"
    echo "   - Collection not properly configured"
    echo "   - Posts missing required front matter"
    echo "   - Jekyll not recognizing the collection"
else
    echo "✓ Everything looks good! The 404 might be a different issue."
fi
echo ""
echo "Full build log saved to: build-output.txt"