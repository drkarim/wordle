import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final state = game.state;
    final isWin = state.status == GameStatus.won;
    final isGaveUp = state.status == GameStatus.gaveUp;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWin) ...[
              const Icon(Icons.celebration, size: 48, color: Colors.amber),
              const SizedBox(height: 12),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You got it in ${state.currentRow} ${state.currentRow == 1 ? "guess" : "guesses"}!',
                style: const TextStyle(fontSize: 16),
              ),
            ] else if (isGaveUp) ...[
              const Icon(Icons.flag, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              const Text(
                'You gave up!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The word was ${state.targetWord}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ] else ...[
              const Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Better luck next time!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The word was ${state.targetWord}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final text = game.getShareText();
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    game.newGame();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
