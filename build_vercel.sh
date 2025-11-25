#!/bin/bash
# Build script for Flutter Web on Vercel
export PATH="$PATH:$(pwd)/flutter/bin"
flutter pub get
flutter build web
