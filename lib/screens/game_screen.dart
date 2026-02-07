import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/keyboard.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/stats_dialog.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const GameScreen({super.key, required this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final game = context.read<GameProvider>();
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter) {
      game.submitGuess();
    } else if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      game.deleteLetter();
    } else {
      final label = event.logicalKey.keyLabel;
      if (label.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(label)) {
        game.addLetter(label.toUpperCase());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'WORDLE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<GameProvider>(
              builder: (context, game, child) {
                final hintsRemaining = game.state.hintsRemaining;
                final canUseHint = game.state.status == GameStatus.playing && hintsRemaining > 0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline),
                      onPressed: canUseHint
                          ? () => game.revealHint()
                          : null,
                      tooltip: canUseHint
                          ? 'Reveal hint ($hintsRemaining left)'
                          : 'No hints remaining',
                    ),
                    if (hintsRemaining > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$hintsRemaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () {
                final game = context.read<GameProvider>();
                if (game.state.status != GameStatus.playing) return;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Give Up?'),
                    content: const Text('Are you sure you want to reveal the word?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          game.giveUp();
                        },
                        child: const Text('Reveal Word'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Give Up',
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<GameProvider>(),
                    child: const StatsDialog(),
                  ),
                );
              },
              tooltip: 'Statistics',
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme,
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, child) {
              // Show error message as snackbar
              if (game.state.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        game.state.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      behavior: SnackBarBehavior.floating,
                      width: 200,
                      duration: const Duration(seconds: 1),
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                });
              }

              // Show game over dialog
              if (game.state.status != GameStatus.playing && !_dialogShown) {
                _dialogShown = true;
                final delay = game.state.status == GameStatus.gaveUp
                    ? const Duration(milliseconds: 300)
                    : const Duration(milliseconds: 2000);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(delay, () {
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<GameProvider>(),
                        child: const GameOverDialog(),
                      ),
                    ).then((_) => _dialogShown = false);
                  });
                });
              }

              if (game.state.status == GameStatus.playing) {
                _dialogShown = false;
              }

              return Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: GameGrid(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4, right: 4),
                    child: GameKeyboard(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
