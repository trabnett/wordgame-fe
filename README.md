# WordGame Frontend

Flutter web app for WordGame — a Wordle-meets-Scrabble multiplayer word game. See `ai_context/proposal.md` in the project root for the full product proposal.

## Tech Stack

- **Framework:** Flutter 3.11+ (web)
- **Routing:** go_router
- **HTTP:** http package
- **WebSockets:** web_socket_channel
- **Local Storage:** shared_preferences
- **Backend:** Django REST Framework + Django Channels (separate repo in `wordgame-be/`)

## Prerequisites

- Flutter 3.11+ ([install guide](https://docs.flutter.dev/get-started/install))
- Chrome (for web development)
- Backend running on port 8181 (see `wordgame-be/README.md`)

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

### Hot reload

- Press `r` in the terminal for hot reload (keeps state)
- Press `R` for hot restart (resets state)

## Configuration

API and WebSocket base URLs are set in `lib/config/constants.dart`:

```dart
const String apiBaseUrl = 'http://localhost:8181/api';
const String wsBaseUrl = 'ws://localhost:8181/ws';
```

## Testing Multiplayer Locally

To test with two players on one machine, open two browser windows (use an incognito window for the second player so they get separate localStorage/tokens):

1. **Window 1:** Log in as Player 1 → Create a game → lands on waiting screen
2. **Window 2 (incognito):** Log in as Player 2 → Find a game → Join
3. Both windows auto-navigate to the game screen with the same board and hand

## Routes

| Path | Screen | Auth Required | Description |
|------|--------|---------------|-------------|
| `/` | HomeScreen | No | Landing page |
| `/welcome` | WelcomeScreen | No | API connection test |
| `/login` | LoginScreen | No | Phone number login |
| `/lobby` | LobbyScreen | Yes | Create game, find game, or invite by phone |
| `/find` | FindGameScreen | Yes | Live list of waiting games (WebSocket) |
| `/waiting/:gameId` | WaitingScreen | Yes | Waiting for opponent (WebSocket, auto-navigates on join) |
| `/game/:gameId` | GameScreen | Yes | Multiplayer game board (WebSocket) |
| `/user` | UserScreen | Yes | User profile |

Auth guard: logged-in users on `/` or `/login` redirect to `/lobby`. Unauthenticated users on protected routes redirect to `/login`.

## Project Structure

```
lib/
├── main.dart                  # App entry point, AuthService init
├── config/
│   ├── constants.dart         # API and WebSocket base URLs
│   └── router.dart            # GoRouter route definitions + auth redirects
├── screens/
│   ├── home_screen.dart       # Landing page
│   ├── welcome_screen.dart    # API test screen
│   ├── login_screen.dart      # Phone login
│   ├── lobby_screen.dart      # Game creation, invite by phone
│   ├── find_game_screen.dart  # Browse and join waiting games (WebSocket)
│   ├── waiting_screen.dart    # Wait for opponent (WebSocket)
│   ├── game_screen.dart       # Game board with drag-and-drop tiles (WebSocket)
│   ├── user_screen.dart       # User profile
│   └── not_found_screen.dart  # 404 page
├── services/
│   ├── api_service.dart       # REST API calls with automatic token refresh
│   └── auth_service.dart      # JWT token storage, login/logout state
└── widgets/
    └── scrabble_tile.dart     # Reusable tile widget
```

## Key Features

- **Real-time game sync:** WebSocket connections for lobby updates, waiting room, and in-game state
- **Drag-and-drop tiles:** Draggable Scrabble tiles from hand to board slots
- **Optimistic updates:** Tile placements update locally immediately, then sync from server
- **Auto token refresh:** API calls that receive a 401 automatically refresh the JWT and retry
- **Game-over overlay:** Winner sees trophy + "You win!", loser sees "You lost!", both get "Back to Lobby"
