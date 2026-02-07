import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<GameProvider>().stats;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(value: stats.gamesPlayed.toString(), label: 'Played'),
                _StatItem(value: '${stats.winPercentage}', label: 'Win %'),
                _StatItem(value: stats.currentStreak.toString(), label: 'Current\nStreak'),
                _StatItem(value: stats.maxStreak.toString(), label: 'Max\nStreak'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Guess Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(6, (i) {
              final count = stats.guessDistribution[i];
              final maxCount = stats.guessDistribution.reduce(
                (a, b) => a > b ? a : b,
              );
              final fraction = maxCount == 0 ? 0.0 : count / maxCount;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 24),
                              width: fraction == 0
                                  ? 24
                                  : constraints.maxWidth * fraction,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: count > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
