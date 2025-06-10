import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../auth/login_screen.dart';
import 'service_list_screen.dart';
import '../../screens/admin/create_service_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const LoginScreen();
    }

    // Tentukan layar yang tersedia berdasarkan peran pengguna
    final List<Widget> userScreens = [
      const ServiceListScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> adminScreens = [
      const ServiceListScreen(),
      const AdminCreateServiceScreen(),
      const ProfileScreen(),
    ];

    final List<NavigationDestination> userDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.list),
        label: 'Layanan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final List<NavigationDestination> adminDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.list),
        label: 'Layanan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_outline),
        label: 'Buat Layanan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final isAdministrator = user.role == 'admin';
    final currentScreens = isAdministrator ? adminScreens : userScreens;
    final currentDestinations = isAdministrator ? adminDestinations : userDestinations;

    // Jika indeks yang dipilih melebihi jumlah layar yang tersedia untuk non-admin,
    // reset ke indeks 0 (Layanan).
    if (!isAdministrator && _selectedIndex >= userScreens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: currentScreens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: currentDestinations,
      ),
    );
  }
} 