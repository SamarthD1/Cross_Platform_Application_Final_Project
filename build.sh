#!/bin/bash
set -e

if ! command -v flutter &> /dev/null
then
    echo "=== Installing Flutter SDK on Vercel ==="
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
    export PATH="$PATH:$(pwd)/_flutter/bin"
fi

echo "=== Building Flutter Web Release ==="
flutter build web --release

cp vercel.json build/web/vercel.json || true
echo "=== Release Build Ready for Vercel ==="
