class GameStats {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;

  const GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const [0, 0, 0, 0, 0, 0],
  });

  int get winPercentage =>
      gamesPlayed == 0 ? 0 : ((gamesWon / gamesPlayed) * 100).round();

  GameStats recordWin(int attempts) {
    final newDistribution = List<int>.from(guessDistribution);
    if (attempts >= 1 && attempts <= 6) {
      newDistribution[attempts - 1]++;
    }
    final newStreak = currentStreak + 1;
    return GameStats(
      gamesPlayed: gamesPlayed + 1,
      gamesWon: gamesWon + 1,
      currentStreak: newStreak,
      maxStreak: newStreak > maxStreak ? newStreak : maxStreak,
      guessDistribution: newDistribution,
    );
  }

  GameStats recordLoss() {
    return GameStats(
      gamesPlayed: gamesPlayed + 1,
      gamesWon: gamesWon,
      currentStreak: 0,
      maxStreak: maxStreak,
      guessDistribution: List<int>.from(guessDistribution),
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'guessDistribution': guessDistribution,
      };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
        gamesPlayed: json['gamesPlayed'] ?? 0,
        gamesWon: json['gamesWon'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        maxStreak: json['maxStreak'] ?? 0,
        guessDistribution:
            List<int>.from(json['guessDistribution'] ?? [0, 0, 0, 0, 0, 0]),
      );
}
