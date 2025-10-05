# Vegolo 🦎

A mobile app that helps users identify whether products are vegan by scanning ingredient lists with AI-powered camera analysis.

## Overview

Vegolo uses on-device AI and OCR to provide instant feedback on whether a product is vegan-friendly. Simply point your camera at an ingredient list, and our chameleon mascot will guide you with real-time analysis.

### Key Features

- **Real-time scanning**: Instant ingredient analysis using your camera
- **Offline-first**: Works without internet connection
- **AI-powered**: Uses Google Gemma 3n for intelligent ingredient recognition
- **Multi-language support**: OCR supports 50+ languages
- **Scan history**: Keep track of your past scans with visual thumbnails
- **Trust & transparency**: Clear explanations and confidence scores

### The Mascot

Our friendly chameleon (with glasses!) changes color based on analysis results:
- 🟢 Green = Vegan
- 🔴 Red = Non-vegan
- 🟡 Yellow = Uncertain

## Tech Stack

- **Framework**: Flutter (iOS & Android)
- **AI/ML**: Google Gemma 3n via TensorFlow Lite
- **OCR**: Google ML Kit (offline)
- **State Management**: BLoC pattern
- **Database**: SQLite with drift
- **Architecture**: Clean Architecture with feature-based structure

## Development Status

Currently in **Phase 1 (MVP)** - building core functionality with camera integration, OCR, and rule-based vegan detection.

### Roadmap

- ✅ Phase 0: Research & prototyping
- 🚧 Phase 1: MVP with camera + OCR + basic detection
- 📋 Phase 2: AI integration with Gemma 3n
- 📋 Phase 3: Polish, animations & internationalization

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Device or emulator with camera support

### Installation
```bash
# Clone the repository
git clone https://github.com/Erik-Edward/Vegolo.git

# Navigate to project directory
cd Vegolo

# Install dependencies
flutter pub get

# Run the app
flutter run
Project Structure
lib/
├── core/           # Shared infrastructure
├── features/       # Feature modules (scanning, history, etc.)
└── shared/         # Shared widgets and utilities

Contributing
This is currently a personal project in active development. Contributions, ideas, and feedback are welcome!
Privacy & Security

Privacy-first: No account required, on-device processing by default
Transparent: Open about confidence levels and uncertainty
User control: Full control over scan history and data

License
TBD
Contact
For questions or feedback, please open an issue on GitHub.

Made with 💚 for the vegan community