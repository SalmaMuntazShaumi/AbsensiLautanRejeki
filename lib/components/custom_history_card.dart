import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lautanrejeki/models/attendance_history_model.dart';
import 'package:lautanrejeki/src/colors.dart';

class CustomHistoryCard extends StatelessWidget {

  final AttendanceHistoryModel history;

  const CustomHistoryCard({
    super.key,
    required this.history,
  });

  String formattedDate(String? date) {

    if (date == null) return '-';

    try {

      final parsed = DateTime.parse(date);

      return DateFormat(
        'EEEE, dd MMMM yyyy',
        'id_ID',
      ).format(parsed);

    } catch (_) {

      return '-';

    }
  }

  Widget buildStatusBadge() {

    Color color;
    IconData icon;
    String label;

    switch (history.status) {

      case 'leave':

        color = Colors.orange;
        icon = Icons.beach_access;
        label = 'Cuti';
        break;

      case 'late':

        color = Colors.red;
        icon = Icons.access_time_filled;
        label = 'Terlambat';
        break;

      case 'present':

        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Hadir';
        break;

      default:

        color = Colors.grey;
        icon = Icons.info;
        label = history.status ?? '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 16,
            color: color,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeCard({
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(

          children: [

            Icon(
              icon,
              color: color,
              size: 28,
            ),

            const SizedBox(width: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeaveCard() {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        children: [

          const Icon(
            Icons.beach_access,
            color: Colors.orange,
            size: 40,
          ),

          const SizedBox(height: 12),

          const Text(
            'Sedang Cuti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Approved Time Off',
            style: TextStyle(
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Expanded(
                child: Text(
                  formattedDate(history.date),

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),

              buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 20),

          history.status == 'leave'

              ? buildLeaveCard()

              : Row(
            children: [

              buildTimeCard(
                value: history.clockIn ?? '-',
                icon: Icons.login,
                color: Colors.green,
              ),

              const SizedBox(width: 12),

              buildTimeCard(
                value: history.clockOut ?? '-',
                icon: Icons.logout,
                color: Colors.red,
              ),
            ],
          ),

          if (history.earlyOutReason != null &&
              history.earlyOutReason!.isNotEmpty)

            Padding(
              padding: const EdgeInsets.only(top: 16),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Alasan Pulang Cepat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      history.earlyOutReason!,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}