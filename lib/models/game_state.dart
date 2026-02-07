import 'letter_state.dart';

enum GameStatus { playing, won, lost, gaveUp }

class TileData {
  final String letter;
  final LetterState state;

  const TileData({this.letter = '', this.state = LetterState.empty});

  TileData copyWith({String? letter, LetterState? state}) {
    return TileData(
      letter: letter ?? this.letter,
      state: state ?? this.state,
    );
  }
}

class GameState {
  final List<List<TileData>> board;
  final int currentRow;
  final int currentCol;
  final GameStatus status;
  final String targetWord;
  final Map<String, LetterState> keyboardStates;
  final String? errorMessage;

  const GameState({
    required this.board,
    this.currentRow = 0,
    this.currentCol = 0,
    this.status = GameStatus.playing,
    required this.targetWord,
    this.keyboardStates = const {},
    this.errorMessage,
  });

  GameState copyWith({
    List<List<TileData>>? board,
    int? currentRow,
    int? currentCol,
    GameStatus? status,
    String? targetWord,
    Map<String, LetterState>? keyboardStates,
    String? errorMessage,
  }) {
    return GameState(
      board: board ?? this.board,
      currentRow: currentRow ?? this.currentRow,
      currentCol: currentCol ?? this.currentCol,
      status: status ?? this.status,
      targetWord: targetWord ?? this.targetWord,
      keyboardStates: keyboardStates ?? this.keyboardStates,
      errorMessage: errorMessage,
    );
  }
}
