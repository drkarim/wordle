import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/letter_state.dart';

class KeyboardKey extends StatelessWidget {
  final String label;
  final LetterState? state;
  final VoidCallback onTap;
  final bool isWide;

  const KeyboardKey({
    super.key,
    required this.label,
    this.state,
    required this.onTap,
    this.isWide = false,
  });

  Color _getKeyColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (state == null || state == LetterState.empty || state == LetterState.typing) {
      return isDark ? AppColors.keyBgDark : AppColors.keyBgLight;
    }
    switch (state!) {
      case LetterState.correct:
        return isDark ? AppColors.correctGreenDark : AppColors.correctGreen;
      case LetterState.present:
        return isDark ? AppColors.presentYellowDark : AppColors.presentYellow;
      case LetterState.absent:
        return isDark ? AppColors.absentGrayDark : AppColors.absentGray;
      default:
        return isDark ? AppColors.keyBgDark : AppColors.keyBgLight;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (state == LetterState.correct ||
        state == LetterState.present ||
        state == LetterState.absent) {
      return Colors.white;
    }
    return isDark ? AppColors.textDark : AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    final isIcon = label == 'DEL';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
      child: Material(
        color: _getKeyColor(context),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: isWide ? 56 : 35,
            height: 52,
            alignment: Alignment.center,
            child: isIcon
                ? Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: _getTextColor(context),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: isWide ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(context),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
