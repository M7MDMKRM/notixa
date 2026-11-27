#!/bin/bash
set -e

echo "🚀 Preparing Notixa on GitHub Codespaces..."

# 1. Install Flutter if not already present
if ! command -v flutter &> /dev/null; then
    if [ ! -d "$HOME/flutter" ]; then
        echo "📦 Downloading Flutter SDK (quick shallow clone)..."
        git clone -b stable --depth 1 https://github.com/flutter/flutter.git $HOME/flutter
    fi
    export PATH="$PATH:$HOME/flutter/bin"
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
fi

export PATH="$PATH:$HOME/flutter/bin"

echo "⚡ Flutter version:"
flutter --version

echo "🧹 Cleaning stale build caches..."
flutter clean

echo "📦 Installing project packages..."
flutter pub get

echo "🌐 Enabling web support..."
flutter config --enable-web

echo "🚀 Launching Notixa Web on port 8080..."
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
