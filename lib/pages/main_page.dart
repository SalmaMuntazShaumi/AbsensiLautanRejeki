import 'package:flutter/material.dart';
import 'package:lautanrejeki/components/bottom_navbar.dart';
import 'package:lautanrejeki/pages/history_page.dart';
import 'package:lautanrejeki/pages/home_page.dart';
import 'package:lautanrejeki/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: CustomBottomNavbar(

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
