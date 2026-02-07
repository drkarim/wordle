import 'dart:math';
import '../constants/word_list.dart';

class WordService {
  final Random _random = Random();

  String getRandomWord() {
    return answerWords[_random.nextInt(answerWords.length)];
  }

  bool isValidWord(String word) {
    final lower = word.toLowerCase();
    return validWords.contains(lower);
  }
}
