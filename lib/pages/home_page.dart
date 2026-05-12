import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/attendance/attendance_bloc.dart';
import 'package:lautanrejeki/components/custom_absent_card.dart';
import 'package:lautanrejeki/repositories/users_repository.dart';

import '../bloc/attendance/attendance_event.dart';
import '../src/colors.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsersRepository userRepo = UsersRepository();

  String name = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchUser();

    context.read<AttendanceBloc>().add(
      GetAttendanceToday(
        token: widget.token,
      ),
    );
  }

  Future<void> fetchUser() async {
    try {
      final data = await userRepo.fetchUserData(widget.token);

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
            CustomAbsentCard(token: widget.token,)
          ],
        ),
      ),
    );
  }
}