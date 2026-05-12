import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lautanrejeki/src/colors.dart';

class CustomBottomNavbar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      // margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: CupertinoIcons.house_alt,
            label: 'Home',
          ),

          _buildNavItem(
            index: 1,
            icon: CupertinoIcons.clock_fill,
            label: 'History',
          ),

          _buildNavItem(
            index: 2,
            icon: CupertinoIcons.person_fill,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {

    final bool isSelected = currentIndex == index;

    return GestureDetector(

      onTap: () => onTap(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.12)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : Colors.grey,
              size: 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,

                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}