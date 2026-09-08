// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'newsfeed_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'News Feed',
    'Notifications',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final screens = [
      const NewsfeedScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (authProvider.user != null)
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    authProvider.user!.image.isNotEmpty
                        ? NetworkImage(
                            authProvider.user!.image,
                          )
                        : null,
                child:
                    authProvider.user!.image.isEmpty
                        ? Text(
                            authProvider.user!.firstName
                                .isNotEmpty
                                ? authProvider
                                    .user!
                                    .firstName[0]
                                    .toUpperCase()
                                : '?',
                          )
                        : null,
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.notifications_none_outlined,
            ),
            selectedIcon: Icon(
              Icons.notifications,
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}