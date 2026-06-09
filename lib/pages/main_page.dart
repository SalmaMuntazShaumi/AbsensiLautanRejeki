import 'package:flutter/material.dart';
import 'package:lautanrejeki/components/bottom_navbar.dart';
import 'package:lautanrejeki/pages/history_page.dart';
import 'package:lautanrejeki/pages/home_page.dart';
import 'package:lautanrejeki/pages/location_page.dart';
import 'package:lautanrejeki/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  String role;
  MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  List<Widget> get pages {
    final isDriver = widget.role.toLowerCase() == 'driver';
    print('Role: ${widget.role} | isDriver: $isDriver'); // ← tambah ini
    return [
      const HomePage(),
      const HistoryPage(),
      if (isDriver) LocationPage(role: widget.role),
      const ProfilePage(),
    ];
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _showExitConfirmation(context);
      },
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: CustomBottomNavbar(
          role: widget.role,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}