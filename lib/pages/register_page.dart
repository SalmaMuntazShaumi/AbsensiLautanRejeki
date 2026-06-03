import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/components/custom_text_field.dart';
import 'package:lautanrejeki/src/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? selectedRole = null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bdController.dispose();
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
            if (state is AuthRegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              // Navigate back to login after successful registration
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              });
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
                  'Daftar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Silahkan daftarkan akun anda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Image.asset('assets/login.png', height: 200),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.only(right: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      items: [
                        const DropdownMenuItem(
                          child: Text('Pilih Role'),
                          value: null,
                        ),
                        DropdownMenuItem(
                          child: const Text('Driver'),
                          value: 'Driver',
                        ),
                        DropdownMenuItem(
                          child: const Text('Employee'),
                          value: 'Employee',
                        ),
                        DropdownMenuItem(
                          child: const Text('Supervisor'),
                          value: 'Supervisor',
                        ),
                        DropdownMenuItem(
                          child: const Text('Admin'),
                          value: 'Admin',
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                      hint: const Text('Pilih Role'),
                      borderRadius: BorderRadius.circular(8),
                      isExpanded: true,
                      itemHeight: 60,
                      style: const TextStyle(color: AppColors.textColor),
                      value: selectedRole,
                      underline: const SizedBox(),
                    ),
                  ),
                ),
              ),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nama Lengkap',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Nomor Telepon',
              ),
              const SizedBox(height: 20),
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
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _bdController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _bdController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36),
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
                              final name = _nameController.text;
                              final role = selectedRole;
                              final phone = _phoneController.text;
                              final bd = _bdController.text;
                              final email = _emailController.text;
                              final password = _passwordController.text;

                              if (name.isEmpty ||
                                  phone.isEmpty ||
                                  bd.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  role == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please fill in all fields'),
                                  ),
                                );
                                return;
                              }

                              context.read<AuthBloc>().add(
                                    RegisterRequested(
                                      name: name,
                                      role: role,
                                      phone: phone,
                                      birthDate: bd,
                                      email: email,
                                      password: password,
                                    ),
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
                          : const Text('Daftar'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Sudah punya akun? ',
                    style: const TextStyle(color: AppColors.textColor),
                    children: [
                      TextSpan(
                        text: 'Masuk disini',
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.pop(context);
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
