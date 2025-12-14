#!/bin/bash
set -e

echo "🔄 Syncing monikasanoria-src (source only)"

# Safety check
if [ ! -d ".git" ]; then
  echo "❌ Not a git repository. Abort."
  exit 1
fi

git pull --rebase
git status

echo "✅ Source synced. No deployment performed."

