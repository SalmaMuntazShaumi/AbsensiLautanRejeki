import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      context.read<AuthBloc>().add(AuthStatusChanged());
      await NotificationService.instance.scheduleClockInReminder();
      await NotificationService.instance.scheduleClockOutReminder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthSuccess) {
          final role = state.userData['role'] ?? '';  // ← ambil dari state
          Navigator.pushReplacementNamed(  // ← pakai pushReplacementNamed bukan pushNamed
            context,
            '/main',
            arguments: {'role': role},
          );
        }

        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            "assets/company.png",
            width: 120,
          ),
        ),
      ),
    );
  }
}