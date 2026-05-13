import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'alerts/alerts_screen.dart';
import 'pets/pet_list_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    PetListScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pets),
            label: l.tabPets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications),
            label: l.tabAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l.tabSettings,
          ),
        ],
      ),
    );
  }
}