import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lautanrejeki/firebase_options.dart';

import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/attendance/attendance_bloc.dart';
import 'package:lautanrejeki/pages/location_page.dart';
import 'package:lautanrejeki/pages/reports_page.dart';

import 'package:lautanrejeki/repositories/auth_repository.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';

import 'package:lautanrejeki/services/notification_service.dart';

import 'package:lautanrejeki/pages/login_page.dart';
import 'package:lautanrejeki/pages/register_page.dart';
import 'package:lautanrejeki/pages/main_page.dart';
import 'package:lautanrejeki/pages/history_page.dart';
import 'package:lautanrejeki/pages/profile_page.dart';
import 'package:lautanrejeki/pages/timeoff_page.dart';
import 'package:lautanrejeki/pages/timoff_history_page.dart';
import 'package:lautanrejeki/pages/admin_settings_page.dart';
import 'package:lautanrejeki/pages/otp_page.dart';
import 'package:lautanrejeki/pages/splash_screen.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Locale Indonesia
  await initializeDateFormatting('id_ID');

  await _clearSessionIfFreshInstall();

  // Notification
  await NotificationService.instance.initNotification();
  runApp(const MyApp());
}

Future<void> _clearSessionIfFreshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  if (isFirstRun) {
    await SessionService.clearSession();
    await prefs.setBool('is_first_run', false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (_) => AttendanceRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(
              context.read<AttendanceRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lautan Rejeki',
          home: const SplashScreen(),
          onGenerateRoute: generateRoute,
        ),
      ),
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case '/main':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MainPage(
            role: args?['role'] as String? ?? '',
          ),
        );

      case '/history':
        return MaterialPageRoute(
          builder: (_) => const HistoryPage(),
        );

      case 'location':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LocationPage(role: args?['role'] ?? ''),
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );

      case '/timeoff':
        return MaterialPageRoute(
          builder: (_) => const TimeOffPage(),
        );

      case '/timeoff_history':
        return MaterialPageRoute(
          builder: (_) => const TimeOffHistoryPage(),
        );

      case '/reports':
        return MaterialPageRoute(
            builder: (_) => const ReportsPage());

      case '/admin_settings':
        return MaterialPageRoute(
          builder: (_) => const AdminSettingsPage(),
        );

      case '/otp':
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null || args['phone'] == null) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => OtpPage(
            phoneNumber: args['phone'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }
}