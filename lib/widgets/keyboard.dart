import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/game_config.dart';
import '../providers/game_provider.dart';
import 'keyboard_key.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: GameConfig.keyboardLayout.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isWide = key == 'ENTER' || key == 'DEL';
                return KeyboardKey(
                  label: key,
                  isWide: isWide,
                  state: game.state.keyboardStates[key],
                  onTap: () => _handleKeyTap(context, key),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  void _handleKeyTap(BuildContext context, String key) {
    final game = context.read<GameProvider>();
    if (key == 'ENTER') {
      game.submitGuess();
    } else if (key == 'DEL') {
      game.deleteLetter();
    } else {
      game.addLetter(key);
    }
  }
}
