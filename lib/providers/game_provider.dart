import 'package:flutter/material.dart';
import '../constants/game_config.dart';
import '../models/game_state.dart';
import '../models/letter_state.dart';
import '../models/stats.dart';
import '../services/word_service.dart';
import '../services/stats_service.dart';

class GameProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final StatsService _statsService = StatsService();

  late GameState _state;
  GameStats _stats = const GameStats();

  // Tracks columns with correctly guessed letters (col -> letter)
  Map<int, String> _correctPositions = {};

  // Animation triggers
  bool _shouldShake = false;
  int _revealRow = -1;
  int _popCol = -1;
  int _hintCol = -1;

  GameProvider() {
    _initGame();
    _loadStats();
  }

  GameState get state => _state;
  GameStats get stats => _stats;
  bool get shouldShake => _shouldShake;
  int get revealRow => _revealRow;
  int get popCol => _popCol;
  int get hintCol => _hintCol;

  void _initGame() {
    final target = _wordService.getRandomWord().toUpperCase();
    _state = GameState(
      board: List.generate(
        GameConfig.maxAttempts,
        (_) => List.generate(
          GameConfig.wordLength,
          (_) => const TileData(),
        ),
      ),
      targetWord: target,
    );
  }

  Future<void> _loadStats() async {
    _stats = await _statsService.loadStats();
    notifyListeners();
  }

  int _nextWritableCol(int from) {
    int col = from;
    while (col < GameConfig.wordLength && _correctPositions.containsKey(col)) {
      col++;
    }
    return col;
  }

  int _prevWritableCol(int from) {
    int col = from - 1;
    while (col >= 0 && _correctPositions.containsKey(col)) {
      col--;
    }
    return col;
  }

  void addLetter(String letter) {
    if (_state.status != GameStatus.playing) return;

    final col = _nextWritableCol(_state.currentCol);
    if (col >= GameConfig.wordLength) return;

    final newBoard = _copyBoard();
    newBoard[_state.currentRow][col] = TileData(
      letter: letter.toUpperCase(),
      state: LetterState.typing,
    );

    _popCol = col;

    _state = _state.copyWith(
      board: newBoard,
      currentCol: _nextWritableCol(col + 1),
      errorMessage: null,
    );
    notifyListeners();

    // Reset pop animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _popCol = -1;
    });
  }

  void deleteLetter() {
    if (_state.status != GameStatus.playing) return;

    final col = _prevWritableCol(_state.currentCol);
    if (col < 0) return;

    final newBoard = _copyBoard();
    newBoard[_state.currentRow][col] = const TileData();

    _state = _state.copyWith(
      board: newBoard,
      currentCol: col,
      errorMessage: null,
    );
    notifyListeners();
  }

  bool _isRowComplete(int row) {
    for (int c = 0; c < GameConfig.wordLength; c++) {
      if (_state.board[row][c].letter.isEmpty) return false;
    }
    return true;
  }

  void submitGuess() {
    if (_state.status != GameStatus.playing) return;
    if (!_isRowComplete(_state.currentRow)) return;

    final guess = _state.board[_state.currentRow]
        .map((t) => t.letter)
        .join();

    if (!_wordService.isValidWord(guess)) {
      _state = _state.copyWith(errorMessage: 'Not in word list');
      _shouldShake = true;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 600), () {
        _shouldShake = false;
        _state = _state.copyWith(errorMessage: null);
        notifyListeners();
      });
      return;
    }

    // Evaluate the guess
    final target = _state.targetWord;
    final newBoard = _copyBoard();
    final newKeyStates = Map<String, LetterState>.from(_state.keyboardStates);

    final letterStates = _evaluateGuess(guess, target);

    for (int i = 0; i < GameConfig.wordLength; i++) {
      newBoard[_state.currentRow][i] = TileData(
        letter: guess[i],
        state: letterStates[i],
      );

      final key = guess[i];
      final current = newKeyStates[key];
      final newState = letterStates[i];

      // Only upgrade keyboard state: absent -> present -> correct
      if (current == null ||
          current == LetterState.empty ||
          current == LetterState.typing) {
        newKeyStates[key] = newState;
      } else if (current == LetterState.absent && newState != LetterState.absent) {
        newKeyStates[key] = newState;
      } else if (current == LetterState.present && newState == LetterState.correct) {
        newKeyStates[key] = newState;
      }
    }

    // Track correct positions for hints on future rows
    for (int i = 0; i < GameConfig.wordLength; i++) {
      if (letterStates[i] == LetterState.correct) {
        _correctPositions[i] = guess[i];
      }
    }

    _revealRow = _state.currentRow;

    final isWin = guess == target;
    final isLastRow = _state.currentRow >= GameConfig.maxAttempts - 1;

    GameStatus newStatus = GameStatus.playing;
    if (isWin) {
      newStatus = GameStatus.won;
    } else if (isLastRow) {
      newStatus = GameStatus.lost;
    }

    // Pre-fill correct letters on all future rows
    if (newStatus == GameStatus.playing) {
      final nextRow = _state.currentRow + 1;
      for (int r = nextRow; r < GameConfig.maxAttempts; r++) {
        for (final entry in _correctPositions.entries) {
          newBoard[r][entry.key] = TileData(
            letter: entry.value,
            state: LetterState.correct,
          );
        }
      }
    }

    _state = _state.copyWith(
      board: newBoard,
      currentRow: _state.currentRow + 1,
      currentCol: _nextWritableCol(0),
      status: newStatus,
      keyboardStates: newKeyStates,
    );
    notifyListeners();

    // Update stats after reveal animation
    if (newStatus == GameStatus.won || newStatus == GameStatus.lost) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        _updateStats(newStatus, _state.currentRow);
      });
    }

    // Reset reveal animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      _revealRow = -1;
    });
  }

  List<LetterState> _evaluateGuess(String guess, String target) {
    final states = List.filled(GameConfig.wordLength, LetterState.absent);
    final targetChars = target.split('');
    final matched = List.filled(GameConfig.wordLength, false);

    // First pass: find correct positions
    for (int i = 0; i < GameConfig.wordLength; i++) {
      if (guess[i] == target[i]) {
        states[i] = LetterState.correct;
        matched[i] = true;
        targetChars[i] = '';
      }
    }

    // Second pass: find present letters
    for (int i = 0; i < GameConfig.wordLength; i++) {
      if (states[i] == LetterState.correct) continue;
      final idx = targetChars.indexOf(guess[i]);
      if (idx != -1) {
        states[i] = LetterState.present;
        targetChars[idx] = '';
      }
    }

    return states;
  }

  Future<void> _updateStats(GameStatus status, int attempts) async {
    if (status == GameStatus.won) {
      _stats = _stats.recordWin(attempts);
    } else {
      _stats = _stats.recordLoss();
    }
    await _statsService.saveStats(_stats);
    notifyListeners();
  }

  void giveUp() {
    if (_state.status != GameStatus.playing) return;
    _state = _state.copyWith(status: GameStatus.gaveUp);
    _updateStats(GameStatus.gaveUp, _state.currentRow);
    notifyListeners();
  }

  void revealHint() {
    if (_state.status != GameStatus.playing) return;
    if (_state.hintsRemaining <= 0) return;

    final currentRow = _state.currentRow;
    final newBoard = _copyBoard();

    // Find leftmost unrevealed position in current row
    int hintPosition = -1;
    for (int col = 0; col < GameConfig.wordLength; col++) {
      if (!_correctPositions.containsKey(col)) {
        hintPosition = col;
        break;
      }
    }

    if (hintPosition == -1) return; // All positions already revealed

    // Place correct letter at hint position
    final correctLetter = _state.targetWord[hintPosition];
    newBoard[currentRow][hintPosition] = TileData(
      letter: correctLetter,
      state: LetterState.correct,
    );

    // Add to correct positions map
    _correctPositions[hintPosition] = correctLetter;

    // Pre-fill this position on all future rows
    for (int r = currentRow + 1; r < GameConfig.maxAttempts; r++) {
      newBoard[r][hintPosition] = TileData(
        letter: correctLetter,
        state: LetterState.correct,
      );
    }

    // Trigger hint animation
    _hintCol = hintPosition;

    // Update state
    _state = _state.copyWith(
      board: newBoard,
      currentCol: _nextWritableCol(_state.currentCol),
      hintsRemaining: _state.hintsRemaining - 1,
    );
    notifyListeners();

    // Reset hint animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _hintCol = -1;
      notifyListeners();
    });
  }

  void newGame() {
    _initGame();
    _correctPositions = {};
    _shouldShake = false;
    _revealRow = -1;
    _popCol = -1;
    _hintCol = -1;
    notifyListeners();
  }

  String getShareText() {
    final rows = _state.currentRow;
    final won = _state.status == GameStatus.won;
    final score = won ? '$rows' : 'X';
    final buffer = StringBuffer('Wordle $score/${GameConfig.maxAttempts}\n\n');

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < GameConfig.wordLength; c++) {
        switch (_state.board[r][c].state) {
          case LetterState.correct:
            buffer.write('🟩');
          case LetterState.present:
            buffer.write('🟨');
          case LetterState.absent:
            buffer.write('⬛');
          default:
            buffer.write('⬜');
        }
      }
      buffer.write('\n');
    }

    return buffer.toString();
  }

  List<List<TileData>> _copyBoard() {
    return _state.board
        .map((row) => row.map((tile) => tile.copyWith()).toList())
        .toList();
  }
}
