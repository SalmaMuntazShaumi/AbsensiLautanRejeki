import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/components/custom_text_field.dart';
import 'package:lautanrejeki/config/app_config.dart';
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
  final TextEditingController _customCompanyCtrl = TextEditingController();

  String _companySelection = 'device'; // device, lautan, luas, custom

  bool _isEmailMode = true; // ✅ false = OTP mode, true = Email mode

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _customCompanyCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initCompany();
  }

  Future<void> _initCompany() async {
    final id = await AppConfig.getCompanyId();
    setState(() {
      if (id == null) {
        _companySelection = 'device';
      } else if (id == 'lautan-rejeki') _companySelection = 'lautan';
      else if (id == 'lautan-rejeki-luas') _companySelection = 'luas';
      else {
        _companySelection = 'custom';
        _customCompanyCtrl.text = id;
      }
    });
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
              // Company picker (select tenant for login)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tenant (wajib untuk login multi-company)', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _companySelection,
                              items: const [
                                DropdownMenuItem(value: 'device', child: Text('Gunakan pengaturan perusahaan tersimpan')),
                                DropdownMenuItem(value: 'lautan', child: Text('lautan-rejeki (preset)')),
                                DropdownMenuItem(value: 'luas', child: Text('lautan-rejeki-luas (preset)')),
                                DropdownMenuItem(value: 'custom', child: Text('Custom')),
                              ],
                              onChanged: (v) async {
                                if (v == null) return;
                                setState(() => _companySelection = v);
                                if (v == 'lautan') {
                                  await AppConfig.setCompanyId('lautan-rejeki');
                                } else if (v == 'luas') {
                                  await AppConfig.setCompanyId('lautan-rejeki-luas');
                                } else {
                                  // device/custom preserve current saved company setting
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_companySelection == 'custom') ...[
                        const SizedBox(height: 8),
                        CustomTextField(controller: _customCompanyCtrl, labelText: 'Company ID'),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final val = _customCompanyCtrl.text.trim();
                                await AppConfig.setCompanyId(val.isEmpty ? null : val);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company saved')));
                              },
                              child: const Text('Save Company'),
                            ),
                          )
                        ]),
                      ],
                      if (_companySelection == 'device') ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Gunakan pengaturan perusahaan yang tersimpan pada perangkat. Jika belum ada, pilih preset atau masukkan custom company ID.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

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
                        backgroundColor: WidgetStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        foregroundColor:
                        const WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () async {
                        if (_companySelection == 'custom') {
                          final customValue = _customCompanyCtrl.text.trim();
                          if (customValue.isNotEmpty) {
                            await AppConfig.setCompanyId(customValue);
                          }
                        }

                        if (!mounted) return;
                        final companyId = await AppConfig.getCompanyId();
                        if (companyId == null || companyId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Pilih tenant perusahaan terlebih dahulu sebelum login.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

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
                              password: password,
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