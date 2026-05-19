import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/attendance/attendance_bloc.dart';
import 'package:lautanrejeki/components/custom_absent_card.dart';
import 'package:lautanrejeki/repositories/users_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';

import '../bloc/attendance/attendance_event.dart';
import '../src/colors.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsersRepository userRepo = UsersRepository();

  String name = '';
  String token = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    initUser();
  }

  Future<void> initUser() async {

    final savedToken =
    await SessionService.getToken();

    if (savedToken == null) {
      return;
    }

    token = savedToken;

    context.read<AttendanceBloc>().add(
      GetAttendanceToday(
        token: token,
      ),
    );

    await fetchUser();
  }

  Future<void> fetchUser() async {
    try {

      final data =
      await userRepo.fetchUserData(token);

      setState(() {
        name = data['name'];
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        name = 'Error';
        isLoading = false;
      });

      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              'assets/company.png',
              width: 70,
              height: 70,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          children: [

            Text(
              'Halo, $name!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Selamat datang di Lautan Rejeki!',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textColor,
              ),
            ),
            CustomAbsentCard(token: token),
            GestureDetector(
              onTap: (){
                 Navigator.pushNamed(context, '/timeoff');
              },
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:.center,
                  children: const [
                    Icon(
                      CupertinoIcons.bag_fill_badge_minus,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pengajuan Time Off/Izin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}