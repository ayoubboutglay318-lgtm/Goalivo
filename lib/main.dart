import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/favorites_service.dart';
import 'services/community_service.dart';
import 'services/commentary_service.dart';
import 'services/football_api_service.dart';
import 'services/goal_alerts_service.dart';
import 'services/news_service.dart';
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
  final apiService = FootballApiService();
  final newsService = NewsService();
  final commentaryService = CommentaryService(apiService: apiService);
  final goalAlerts = GoalAlertsService(
    favoritesService: favs,
    apiService: apiService,
  );
  final community = CommunityService(
    xpService: xp,
    predictionService: predictions,
  );

  await Future.wait([
    favs.load(),
    reactions.load(),
    predictions.load(),
    xp.onAppOpen(),
    community.load(),
  ]);
  try { await NotificationService.instance.init(); } catch (_) {}
  await goalAlerts.load();
  runApp(
    FootbalLiveApp(
      apiService: apiService,
      favoritesService: favs,
      xpService: xp,
      reactionsService: reactions,
      predictionService: predictions,
      goalAlertsService: goalAlerts,
      communityService: community,
      newsService: newsService,
      commentaryService: commentaryService,
    ),
  );
}

class FootbalLiveApp extends StatefulWidget {
  const FootbalLiveApp({
    super.key,
    required this.apiService,
    required this.favoritesService,
    required this.xpService,
    required this.reactionsService,
    required this.predictionService,
    required this.goalAlertsService,
    required this.communityService,
    required this.newsService,
    required this.commentaryService,
  });
  final FootballApiService apiService;
  final FavoritesService favoritesService;
  final XpService xpService;
  final ReactionsService reactionsService;
  final PredictionService predictionService;
  final GoalAlertsService goalAlertsService;
  final CommunityService communityService;
  final NewsService newsService;
  final CommentaryService commentaryService;

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
    final base =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF07060F),
          surfaceContainerHighest: const Color(0xFF120F1E),
          primary: const Color(0xFF7C4DFF),
          onPrimary: Colors.white,
        );
    return ThemeData(
      colorScheme: base,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displaySmall: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: Colors.white),
        headlineMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Colors.white),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: Colors.white),
        titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.white),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F0D1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1E1A2E)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF07060F),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: const Color(0xFF1E1E1E),
        indicatorColor: const Color(0xFF7C4DFF),
        labelColor: const Color(0xFF7C4DFF),
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF07060F),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0C0A18),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black54,
        elevation: 0,
        height: 64,
        indicatorColor: const Color(0xFF7C4DFF).withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 26, color: Color(0xFF7C4DFF));
          }
          return const IconThemeData(size: 24, color: Color(0xFF666666));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C4DFF),
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF666666),
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF4527A0),
            brightness: Brightness.light,
          ).copyWith(
            surface: Colors.white,
            surfaceContainerHighest: const Color(0xFFF2F2F2),
            primary: const Color(0xFF4527A0),
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
        indicatorColor: const Color(0xFF4527A0),
        labelColor: const Color(0xFF4527A0),
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        elevation: 0,
        height: 64,
        indicatorColor: const Color(0xFF4527A0).withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 26, color: Color(0xFF4527A0));
          }
          return const IconThemeData(size: 24, color: Color(0xFF999999));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4527A0),
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF999999),
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KickOra',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: _showOnboarding
          ? OnboardingScreen(
              onDone: () => setState(() => _showOnboarding = false),
            )
          : HomeScreen(
              apiService: widget.apiService,
              favoritesService: widget.favoritesService,
              xpService: widget.xpService,
              reactionsService: widget.reactionsService,
              predictionService: widget.predictionService,
              goalAlertsService: widget.goalAlertsService,
              communityService: widget.communityService,
              newsService: widget.newsService,
              commentaryService: widget.commentaryService,
              themeMode: _themeMode,
              onToggleTheme: _toggleThemeMode,
            ),
    );
  }
}
