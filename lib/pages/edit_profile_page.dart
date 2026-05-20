import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:lautanrejeki/repositories/users_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String phone;
  final String birthdate;
  final String photoUrl;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.birthdate,
    required this.photoUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UsersRepository _usersRepository = UsersRepository();

  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController birthdateController;

  File? selectedImage;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.name,
    );

    phoneController = TextEditingController(
      text: widget.phone,
    );

    birthdateController = TextEditingController(
      text: widget.birthdate,
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await SessionService.getToken();

      if (token == null) return;

      await _usersRepository.updateProfile(
        token: token,
        name: nameController.text,
        phone: phoneController.text,
        birthdate: birthdateController.text,
        image: selectedImage,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectBirthdate() async {
    DateTime initialDate = DateTime.now();

    try {
      if (birthdateController.text.isNotEmpty) {
        initialDate = DateTime.parse(
          birthdateController.text,
        );
      }
    } catch (_) {}

    final pickedDate = await showDatePicker(
      context: context,

      initialDate: initialDate,

      firstDate: DateTime(1950),
      lastDate: DateTime.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),

          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      birthdateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(pickedDate);

      setState(() {});
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),

      child: TextField(
        keyboardType: keyboardType,
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon:
          icon != null
              ? Icon(icon)
              : null,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
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
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            Stack(
              children: [
                CircleAvatar(
                  radius: 60,

                  backgroundColor:
                  AppColors.primaryColor.withOpacity(0.15),

                  backgroundImage:
                  selectedImage != null
                      ? FileImage(selectedImage!)
                      : widget.photoUrl.isNotEmpty
                      ? NetworkImage(widget.photoUrl)
                      : null,

                  child:
                  selectedImage == null &&
                      widget.photoUrl.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 60,
                  )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,

                  child: GestureDetector(
                    onTap: pickImage,

                    child: Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),

                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            buildTextField(
              label: 'Name',
              controller: nameController,
              icon: Icons.person_outline,
            ),

            buildTextField(
              label: 'Phone Number',
              controller: phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            GestureDetector(
              onTap: selectBirthdate,

              child: AbsorbPointer(
                child: buildTextField(
                  label: 'Birthdate',
                  controller: birthdateController,
                  icon: Icons.calendar_month_outlined,
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed:
                isLoading
                    ? null
                    : updateProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child:
                isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}