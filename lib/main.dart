import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/roster_screen.dart';

void main() {
  runApp(const HackTrackerApp());
}

class HackTrackerApp extends StatelessWidget {
  const HackTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackTracker',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Color(0xFF00FF88), // Neon green
          onPrimary: Color(0xFF000000),
          secondary: Color(0xFF0088FF), // Neon blue
          onSecondary: Color(0xFF000000),
          tertiary: Color(0xFFFF0088), // Neon pink
          onTertiary: Color(0xFF000000),
          surface: Color(0xFF0A0A0A), // Very dark
          onSurface: Color(0xFFE0E0E0),
          surfaceContainerHighest: Color(0xFF1A1A1A),
          onSurfaceVariant: Color(0xFFB0B0B0),
          outline: Color(0xFF333333),
          background: Color(0xFF000000),
          onBackground: Color(0xFFE0E0E0),
          error: Color(0xFFFF4444),
          onError: Color(0xFF000000),
        ),
        useMaterial3: true,
        fontFamily: 'Tektur',
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF0F0F0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Color(0xFF00FF88),
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const StatsScreen(),
    const RosterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF0A0A0A),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0A0A0A),
          selectedItemColor: const Color(0xFF00FF88),
          unselectedItemColor: const Color(0xFF666666),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Roster',
            ),
          ],
        ),
      ),
    );
  }
}