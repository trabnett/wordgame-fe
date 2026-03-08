# WordGame Frontend

A Flutter web app for WordGame — a Wordle-meets-Scrabble multiplayer word game. See `ai_context/proposal.md` in the project root for the full product proposal.

## Tech Stack

- **Framework:** Flutter (web)
- **Routing:** go_router
- **HTTP:** http package
- **Backend:** Django REST Framework (separate repo in `wordgame-be/`)

## Prerequisites

- Flutter 3.41+ ([install guide](https://docs.flutter.dev/get-started/install))
- Chrome (for web development)

Verify your setup:

```bash
flutter doctor
```

## Getting Started

### 1. Install dependencies

```bash
cd wordgame-fe
flutter pub get
```

### 2. Start the dev server

```bash
flutter run -d chrome --web-port 3081
```

The app will be available at `http://localhost:3081`.

Make sure the backend is running on port 8181 (see `wordgame-be/README.md`).

### Hot reload

- Press `r` in the terminal for hot reload (keeps state)
- Press `R` for hot restart (resets state)

## Configuration

The API base URL is set in `lib/config/constants.dart`. Default is `http://localhost:8181/api`.

For production builds, override via build flag:

```bash
flutter build web --dart-define=API_BASE_URL=https://yourdomain.com/api
```

## Routes

| Path | Screen | Description |
|------|--------|-------------|
| `/` | HomeScreen | Landing page with Play button |
| `/welcome` | WelcomeScreen | API connection test |
| `/*` | NotFoundScreen | 404 page |

## Project Structure

```
lib/
├── main.dart              # App entry point
├── config/
│   ├── constants.dart     # API base URL
│   └── router.dart        # Route definitions
├── screens/
│   ├── home_screen.dart
│   ├── welcome_screen.dart
│   └── not_found_screen.dart
├── services/
│   └── api_service.dart   # HTTP calls to Django backend
└── widgets/               # Reusable components (empty for now)
```
