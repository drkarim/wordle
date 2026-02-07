import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/game_config.dart';
import '../providers/game_provider.dart';
import 'game_tile.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.shouldShake && !_shakeController.isAnimating) {
          _shakeController.forward(from: 0);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(GameConfig.maxAttempts, (row) {
            final isCurrentRow = row == game.state.currentRow;
            final isRevealRow = row == game.revealRow;

            Widget rowWidget = Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(GameConfig.wordLength, (col) {
                final tile = game.state.board[row][col];
                return Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: GameTile(
                    letter: tile.letter,
                    state: tile.state,
                    shouldReveal: isRevealRow,
                    revealDelay: col * 200,
                    shouldPop: isCurrentRow && col == game.popCol,
                    shouldHint: isCurrentRow && col == game.hintCol,
                  ),
                );
              }),
            );

            if (isCurrentRow && game.shouldShake) {
              rowWidget = AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: rowWidget,
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: rowWidget,
            );
          }),
        );
      },
    );
  }
}
