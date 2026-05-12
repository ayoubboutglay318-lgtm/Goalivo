import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'services/favorites_service.dart';
import 'services/football_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favs = FavoritesService();
  await favs.load();
  runApp(FootbalLiveApp(favoritesService: favs));
}

class FootbalLiveApp extends StatefulWidget {
  const FootbalLiveApp({super.key, required this.favoritesService});
  final FavoritesService favoritesService;

  @override
  State<FootbalLiveApp> createState() => _FootbalLiveAppState();
}

class _FootbalLiveAppState extends State<FootbalLiveApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
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
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.dark,
          ).copyWith(
            surface: const Color(0xFF0E0E0E),
            surfaceContainerHighest: const Color(0xFF1A1A1A),
          ),
      useMaterial3: true,
      cardTheme: const CardThemeData(
        color: Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0E0E0E),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: const Color(0xFF2A2A2A),
        indicatorColor: const Color(0xFF4CAF50),
        labelColor: const Color(0xFF4CAF50),
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF0E0E0E),
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
      title: 'FootbalLive',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: HomeScreen(
        apiService: apiService,
        favoritesService: widget.favoritesService,
        themeMode: _themeMode,
        onToggleTheme: _toggleThemeMode,
      ),
    );
  }
}
