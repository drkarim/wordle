import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';
import 'constants/colors.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatefulWidget {
  const WordleApp({super.key});

  @override
  State<WordleApp> createState() => _WordleAppState();
}

class _WordleAppState extends State<WordleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Wordle',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.bgLight,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.bgLight,
            foregroundColor: AppColors.textLight,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.correctGreen,
            brightness: Brightness.light,
          ),
          snackBarTheme: const SnackBarThemeData(
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bgDark,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.bgDark,
            foregroundColor: AppColors.textDark,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.correctGreenDark,
            brightness: Brightness.dark,
          ),
          snackBarTheme: const SnackBarThemeData(
            contentTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: GameScreen(onToggleTheme: _toggleTheme),
      ),
    );
  }
}
