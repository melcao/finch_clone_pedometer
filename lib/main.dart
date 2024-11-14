import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/bag_screen.dart';
import 'screens/profile_screen.dart';
import 'models/finch_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FinchModel(),
      child: const FinchCareApp(),
    ),
  );
}

class FinchCareApp extends StatelessWidget {
  const FinchCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finch Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFF4E6),
        fontFamily: 'Nunito',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const QuestScreen(),
    const ShopScreen(),
    const FriendsScreen(),
    const BagScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
  items: [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/home_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/quests_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Quests',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/shop_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Shop',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/friends_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Friends',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/bag_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Bag',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/birb_icon.png',
        width: 24,
        height: 24,
      ),
      label: 'Bird',
    ),
  ],
        ),
      ),
    );
  }
}
