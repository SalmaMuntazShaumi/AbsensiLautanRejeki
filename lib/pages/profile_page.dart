import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/repositories/users_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UsersRepository _usersRepository = UsersRepository();

  bool isLoading = true;

  String name = '';
  String email = '';
  String role = '';
  String phone = '';
  String birthdate = '';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final token = await SessionService.getToken();

      if (token == null) {
        return;
      }

      final data = await _usersRepository.fetchUserData(token);

      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        role = data['role'] ?? '';
        phone = data['phone'] ?? '';
        birthdate = data['birthdate'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryColor.withOpacity(
                            0.15,
                          ),

                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',

                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),

                          child: Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildProfileTile(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: email,
                        ),

                        const SizedBox(height: 16),

                        _buildProfileTile(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          value: phone,
                        ),

                        const SizedBox(height: 16),

                        _buildProfileTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Birthdate',
                          value: birthdate,
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            onPressed: () async {
                              await SessionService.clearSession();

                              if (!context.mounted) return;

                              context.read<AuthBloc>().add(LogoutRequested());

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },

                            icon: const Icon(Icons.logout),

                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: AppColors.primaryColor),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
