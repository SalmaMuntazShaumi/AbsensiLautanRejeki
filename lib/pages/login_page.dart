import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/components/custom_text_field.dart';
import 'package:lautanrejeki/pages/register_page.dart';
import 'package:lautanrejeki/src/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );

              // Navigate to home page with token
              Navigator.pushReplacementNamed(
                context, 
                '/main',
                arguments: state.token ?? '',
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 45),
              const Center(
                child: Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Silahkan masuk untuk menggunakan aplikasi ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Image.asset('assets/login.png', height: 200),
              const SizedBox(height: 36),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Lupa password anda? ',
                    style: const TextStyle(color: AppColors.textColor),
                    children: [
                      TextSpan(
                        text: 'Klik disini',
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          // Implement navigation to password recovery page
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        final email = _emailController.text;
                        final password = _passwordController.text;

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields')),
                          );
                          return;
                        }

                        context.read<AuthBloc>().add(
                          LoginRequested(email: email, password: password),
                        );
                      },
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Masuk'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Belum punya akun? ',
                    style: const TextStyle(color: AppColors.textColor),
                    children: [
                      TextSpan(
                        text: 'Daftar disini',
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
