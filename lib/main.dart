import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/components/bottom_navbar.dart';
import 'package:lautanrejeki/pages/login_page.dart';
import 'package:lautanrejeki/pages/main_page.dart';
import 'package:lautanrejeki/pages/register_page.dart';
import 'package:lautanrejeki/pages/splash_screen.dart';

import 'package:lautanrejeki/repositories/auth_repository.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';

import 'bloc/attendance/attendance_bloc.dart';

void main() {
  runApp(const MyApp());
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

      child: Builder(

        builder: (context) {

          return MultiBlocProvider(

            providers: [

              BlocProvider(
                create: (_) => AuthBloc(
                  authRepository:
                  context.read<AuthRepository>(),
                ),
              ),

              BlocProvider(
                create: (_) => AttendanceBloc(
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
          );
        },
      ),
    );
  }

  static Route<dynamic> generateRoute(
      RouteSettings settings,
      ) {

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

        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );

      default:

        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }
}