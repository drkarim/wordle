import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/letter_state.dart';

class GameTile extends StatefulWidget {
  final String letter;
  final LetterState state;
  final bool shouldReveal;
  final int revealDelay;
  final bool shouldPop;
  final bool shouldHint;

  const GameTile({
    super.key,
    required this.letter,
    required this.state,
    this.shouldReveal = false,
    this.revealDelay = 0,
    this.shouldPop = false,
    this.shouldHint = false,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _popController;
  late AnimationController _hintController;
  late Animation<double> _flipAnimation;
  late Animation<double> _popAnimation;
  late Animation<double> _hintAnimation;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addListener(() {
      if (_flipAnimation.value >= 0.5 && !_showResult) {
        setState(() => _showResult = true);
      }
    });

    _popController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );

    _hintController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hintAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _hintController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldReveal && !oldWidget.shouldReveal) {
      Future.delayed(Duration(milliseconds: widget.revealDelay), () {
        if (mounted) _flipController.forward();
      });
    }
    if (widget.shouldPop && !oldWidget.shouldPop) {
      _popController.forward().then((_) {
        if (mounted) _popController.reverse();
      });
    }
    if (widget.shouldHint && !oldWidget.shouldHint) {
      _hintController.forward();
    }
    if (!widget.shouldReveal && oldWidget.shouldReveal) {
      _flipController.reset();
      _showResult = false;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _popController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Color _getTileColor(BuildContext context, LetterState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case LetterState.correct:
        return isDark ? AppColors.correctGreenDark : AppColors.correctGreen;
      case LetterState.present:
        return isDark ? AppColors.presentYellowDark : AppColors.presentYellow;
      case LetterState.absent:
        return isDark ? AppColors.absentGrayDark : AppColors.absentGray;
      default:
        return Colors.transparent;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.letter.isNotEmpty && widget.state == LetterState.typing) {
      return isDark ? AppColors.tileFilledBorderDark : AppColors.tileFilledBorderLight;
    }
    return isDark ? AppColors.tileBorderDark : AppColors.tileBorderLight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRevealed = _showResult &&
        (widget.state == LetterState.correct ||
            widget.state == LetterState.present ||
            widget.state == LetterState.absent);

    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnimation, _popAnimation, _hintAnimation]),
      builder: (context, child) {
        final flipValue = _flipAnimation.value;
        final scaleValue = _popAnimation.value;
        final hintScale = _hintAnimation.value;
        final angle = flipValue * 3.14159;
        final isHinting = widget.shouldHint && _hintController.isAnimating;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle)
            // ignore: deprecated_member_use
            ..scale(scaleValue * hintScale),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isRevealed ? _getTileColor(context, widget.state) : null,
              border: isRevealed
                  ? null
                  : Border.all(
                      color: _getBorderColor(context),
                      width: isHinting ? 3 : 2,
                    ),
              boxShadow: isHinting
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isRevealed
                    ? Colors.white
                    : (isDark ? AppColors.textDark : AppColors.textLight),
              ),
            ),
          ),
        );
      },
    );
  }
}
