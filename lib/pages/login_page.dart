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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailMode = true; // ✅ false = OTP mode, true = Email mode

  @override
  void dispose() {
    _phoneController.dispose();
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
            if (state is OtpSent) {
              Navigator.pushReplacementNamed(
                context,
                '/otp',
                arguments: {'phone': state.phoneNumber},
              );
            } else if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pushReplacementNamed(
                context,
                '/main',
                arguments: {'role': state.userData['role'] ?? ''},  // ← Map
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
                    color: AppColors.textColor,
                  ),
                ),
              ),

              const SizedBox(height: 36),
              Image.asset('assets/login.png', height: 200),
              const SizedBox(height: 24),

              // ✅ Toggle mode
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isEmailMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isEmailMode
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Center(
                          child: Text(
                            'Email',
                            style: TextStyle(
                              color: _isEmailMode
                                  ? Colors.white
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isEmailMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isEmailMode
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Center(
                          child: Text(
                            'Nomor Telepon',
                            style: TextStyle(
                              color: !_isEmailMode
                                  ? Colors.white
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // ✅ Form fields berdasarkan mode
              if (!_isEmailMode) ...[
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Nomor Telepon',
                ),
              ] else ...[
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                ),
              ],

              const SizedBox(height: 20),

              // ✅ Tombol login
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        foregroundColor:
                        const WidgetStatePropertyAll(Colors.white),
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
                        if (_isEmailMode) {
                          // ✅ Login email
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Masukkan email dan password'),
                              ),
                            );
                            return;
                          }

                          context.read<AuthBloc>().add(
                            LoginRequested(
                              email: email,
                              password: password
                            ),
                          );
                        } else {
                          // ✅ Login OTP
                          final phone = _phoneController.text.trim();

                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Masukkan nomor telepon'),
                              ),
                            );
                            return;
                          }

                          context.read<AuthBloc>().add(
                            RequestOtpRequested(
                                phoneNumber: phone),
                          );
                        }
                      },
                      child: state is AuthLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : Text(_isEmailMode ? 'Masuk' : 'Minta OTP'),
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
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
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