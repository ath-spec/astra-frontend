# Astra: Intelligent Wealth & Portfolio Management 🚀

Welcome to **Astra**—a next-generation financial platform designed to bring institutional-grade portfolio analysis and AI-driven insights directly to retail investors. Built with a stunning, cross-platform interface and a lightning-fast Go backend, Astra empowers users to understand, manage, and grow their wealth with unprecedented clarity.

## 🌟 What is Astra?

Astra is a comprehensive wealth management application that aggregates financial data (via mechanisms like MF Central and Account Aggregators) and provides deep, actionable insights into a user's portfolio. It goes beyond simple balance tracking by offering advanced analytics on investment discipline, asset allocation, and historical performance.

## ✨ Core Features

*   **🎙️ AI Financial Assistant:** Integrated with Groq AI and Sarvam TTS, Astra features a blazing-fast, voice-capable AI assistant that helps users understand their finances, ask complex market questions, and receive personalized guidance.
*   **📊 Deep Portfolio Analytics:**
    *   **Discipline:** Tracks SIP consistency and investment behavior.
    *   **Allocation:** Visualizes asset distribution across various financial instruments.
    *   **Performance:** Analyzes historical returns and growth metrics.
*   **🔗 Seamless Aggregation:** Securely connects to MF Central and other financial data sources (via OTP and PAN verification) to build a holistic view of the user's net worth.
*   **📱 Cross-Platform Excellence:** Runs beautifully as a native mobile application (iOS/Android) and a responsive web application, sharing a single unified codebase.
*   **✨ Premium UX/UI:** Designed with "Emil Kowalski" engineering principles, featuring hardware-accelerated animations, buttery-smooth spring physics, and intuitive 3D carousel navigation.

## 🏗️ Technical Architecture

Astra is built using a modern, scalable, and highly performant tech stack:

*   **Frontend:** [Flutter](https://flutter.dev/) (Dart). Utilizes Riverpod for robust state management, GoRouter for deep linking, and Dio for networking.
*   **Backend:** [Go (Golang)](https://go.dev/). A custom, high-performance API server utilizing `go-chi` for routing and optimized for low-latency AI and data processing.
*   **AI & Voice:** Groq API for rapid LLM inference and Sarvam API for natural text-to-speech.
*   **Deployment:** 
    *   **Web App:** Hosted securely on [Netlify](https://www.netlify.com/).
    *   **Backend API:** Deployed seamlessly on [Railway](https://railway.app/).

## 📂 Repository Navigation (Frontend)

The frontend repository follows a clean, feature-first architecture to ensure maintainability as the app scales:

```text
lib/
├── core/                   # Shared utilities, themes, constants, and base widgets
├── features/               # Domain-specific feature modules (The core of the app)
│   ├── auth/               # OTP, PAN verification, and MF Central linking flows
│   ├── chat/               # The AI assistant interface, speech processing, and UI
│   ├── mf/                 # Mutual fund holdings and aggregation logic
│   ├── navigation/         # App shell, bottom navigation, and routing logic
│   └── portfolio_analysis/ # Discipline, Allocation, and Performance analytics tabs
└── main.dart               # Application entry point and initialization
```
*Note: The app curretly uses synthetic data*

## 🚀 Getting Started (Local Development)

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Managed via FVM - version `3.44.9` recommended)
*   Dart SDK

### Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-org/astra-frontend.git
    cd astra-frontend
    ```

2.  **Install the correct Flutter SDK (via FVM):**
    *Note: The Flutter Version Manager (FVM) configuration is already included in this repository. If you don't have the correct Flutter version installed, simply run:*
    ```bash
    fvm install
    ```

3.  **Install Dependencies:**
    ```bash
    fvm flutter pub get
    ```

4.  **Environment Variables:**
    Config like `API_BASE_URL` is **not** read from a `.env` file — a `.env` bundled as a Flutter asset ships as a plain, publicly-fetchable file inside the web/mobile build, which is a real leak vector once anything sensitive lands in it. Instead it's passed in at build/run time via `--dart-define`, so it's compiled directly into the binary.

    Copy the example and fill in real values:
    ```bash
    cp dart_defines.example.json dart_defines.json
    ```
    `dart_defines.json` is gitignored — never commit it. If it's missing or `API_BASE_URL` isn't set, the app throws a clear `StateError` on first network call instead of silently using a wrong/hardcoded URL.

5.  **Run the App:**
    ⚠️ **Every `flutter run` / `flutter build` command needs `--dart-define-from-file=dart_defines.json`, or the app will build/run but crash with `Bad state: API_BASE_URL is not set` on first use.**
    ```bash
    # For Web
    fvm flutter run -d chrome --dart-define-from-file=dart_defines.json

    # For Mobile dev mode
    fvm flutter run --dart-define-from-file=dart_defines.json

    # For Mobile release
    fvm flutter run --release --dart-define-from-file=dart_defines.json
    ```
    Prefer VS Code's Run/Debug panel instead of the terminal — `.vscode/launch.json` already has this flag wired into every configuration, so you don't have to remember it there.

    Building an Android release App Bundle for Play Store? Use `./build_android_release.sh` instead of a bare `flutter build appbundle --release` — it refuses to build if `dart_defines.json` is missing, so the flag can't be silently forgotten on a real release.

---

