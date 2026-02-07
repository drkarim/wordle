# Wordle Game

A fully-featured Wordle clone built with Flutter for Android. Guess the 5-letter word in 6 attempts with color-coded feedback after each guess.

## Features

- **Classic Wordle gameplay** - 6 attempts to guess a 5-letter word
- **Color-coded feedback**
  - Green: correct letter in the correct position
  - Yellow: correct letter in the wrong position
  - Gray: letter not in the word
- **Persistent green hints** - correctly guessed letters (green) stay visible in their position on all subsequent rows
- **On-screen QWERTY keyboard** with dynamic color updates as letters are guessed
- **Physical keyboard support** - works with hardware keyboards (Enter, Backspace, letter keys)
- **Give Up button** - flag icon in the app bar lets you reveal the word with a confirmation prompt
- **Animations** - tile flip reveal, letter pop on typing, row shake for invalid words
- **Dark/Light mode toggle**
- **Statistics tracking** - games played, win %, current & max streak, guess distribution (persisted locally via SharedPreferences)
- **Share results** - copy your emoji grid to clipboard
- **Word validation** - only valid English words are accepted as guesses

## Project Structure

```
lib/
  main.dart                    # App entry point, theme configuration
  constants/
    colors.dart                # App color scheme (light/dark)
    game_config.dart           # Word length, max attempts, keyboard layout
    word_list.dart              # Answer words (~580) and valid guesses (~2,660)
  models/
    game_state.dart            # GameState, TileData, GameStatus enum
    letter_state.dart          # LetterState enum (empty, typing, correct, present, absent)
    stats.dart                 # GameStats model
  providers/
    game_provider.dart         # Core game logic and state management (Provider/ChangeNotifier)
  screens/
    game_screen.dart           # Main game UI, keyboard input handling, app bar
  services/
    word_service.dart          # Random word selection, guess validation
    stats_service.dart         # Stats persistence via SharedPreferences
  widgets/
    game_grid.dart             # 6x5 tile grid with shake animation
    game_tile.dart             # Individual tile with flip/pop animations
    keyboard.dart              # On-screen QWERTY keyboard
    keyboard_key.dart          # Individual keyboard key
    game_over_dialog.dart      # Win/lose/gave-up dialog with share option
    stats_dialog.dart          # Statistics display dialog
```

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.8+)
- [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins installed
- Android SDK (installed via Android Studio)
- An Android emulator or physical Android device

## Setup

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd wordle_game
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Verify your environment:
   ```bash
   flutter doctor
   ```

## Running in Android Studio

1. Open the `wordle_game` folder in Android Studio
2. Wait for the project to sync and index
3. **Select a target device** from the device dropdown in the toolbar:
   - **Android Emulator**: Go to Tools > Device Manager > Create Virtual Device (e.g. Pixel 7, API 34+). Requires hardware virtualization enabled in BIOS (Intel VT-x / AMD SVM) and Windows Hypervisor Platform enabled in Windows Features
   - **Physical Android device**: Connect via USB with Developer Options > USB Debugging enabled
4. Click the Run button (green play icon) or press Shift+F10
5. The app will build and launch on the selected device

## Building the APK

### Debug build
```bash
flutter build apk --debug
```

### Release build
```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Installing on a Phone

1. Build the release APK (see above)
2. Transfer `app-release.apk` to your phone via USB, email, Google Drive, or any file transfer method
3. On your phone, enable **Settings > Security > Install from unknown sources** (or allow your file manager/browser to install apps)
4. Open the APK file on your phone and tap Install

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Persistent local storage for stats |

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider (ChangeNotifier)
- **Target Platform**: Android
