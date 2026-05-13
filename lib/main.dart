import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/favorites_service.dart';
import 'services/football_api_service.dart';
import 'services/notification_service.dart';
import 'services/prediction_service.dart';
import 'services/reactions_service.dart';
import 'services/xp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favs = FavoritesService();
  final xp = XpService();
  final reactions = ReactionsService();
  final predictions = PredictionService();
  await Future.wait([
    favs.load(),
    reactions.load(),
    predictions.load(),
    xp.onAppOpen(),
  ]);
  NotificationService.instance.init();
  runApp(FootbalLiveApp(
    favoritesService: favs,
    xpService: xp,
    reactionsService: reactions,
    predictionService: predictions,
  ));
}

class FootbalLiveApp extends StatefulWidget {
  const FootbalLiveApp({
    super.key,
    required this.favoritesService,
    required this.xpService,
    required this.reactionsService,
    required this.predictionService,
  });
  final FavoritesService favoritesService;
  final XpService xpService;
  final ReactionsService reactionsService;
  final PredictionService predictionService;

  @override
  State<FootbalLiveApp> createState() => _FootbalLiveAppState();
}

class _FootbalLiveAppState extends State<FootbalLiveApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final should = await OnboardingScreen.shouldShow();
    if (mounted) setState(() => _showOnboarding = should);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('theme_mode');
    setState(() {
      _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
  }

  Future<void> _toggleThemeMode() async {
    final nextMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() {
      _themeMode = nextMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      nextMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C853),
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF080808),
      surfaceContainerHighest: const Color(0xFF141414),
      primary: const Color(0xFF00C853),
      onPrimary: Colors.black,
    );
    return ThemeData(
      colorScheme: base,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: const Color(0xFF111111),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1E1E1E)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF080808),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: const Color(0xFF1E1E1E),
        indicatorColor: const Color(0xFF00C853),
        labelColor: const Color(0xFF00C853),
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      scaffoldBackgroundColor: const Color(0xFF080808),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.light,
          ).copyWith(
            surface: Colors.white,
            surfaceContainerHighest: const Color(0xFFF2F2F2),
            primary: const Color(0xFF1B5E20),
          ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: const Color(0xFFCCCCCC),
        indicatorColor: const Color(0xFF1B5E20),
        labelColor: const Color(0xFF1B5E20),
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiService = FootballApiService();

    return MaterialApp(
      title: 'Kick Ora',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: _showOnboarding
          ? OnboardingScreen(onDone: () => setState(() => _showOnboarding = false))
          : HomeScreen(
              apiService: apiService,
              favoritesService: widget.favoritesService,
              xpService: widget.xpService,
              reactionsService: widget.reactionsService,
              predictionService: widget.predictionService,
              themeMode: _themeMode,
              onToggleTheme: _toggleThemeMode,
            ),
    );
  }
}
