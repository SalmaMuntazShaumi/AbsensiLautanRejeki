import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lautanrejeki/models/attendance_history_model.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class CustomHistoryCard extends StatefulWidget {
  final AttendanceHistoryModel history;
  CustomHistoryCard({super.key, required this.history});

  @override
  State<CustomHistoryCard> createState() => _CustomHistoryCardState();
}

class _CustomHistoryCardState extends State<CustomHistoryCard> {

  String formattedDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    try {
      final dateTime = DateTime.parse(date);

      final result = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);

      debugPrint('FORMATTED DATE: $result');

      return result;
    } catch (e) {
      debugPrint('ERROR FORMAT DATE: $e');
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Text(
                formattedDate(widget.history.date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const Spacer(),
              Text(
                widget.history.status!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.history.status == 'Tepat Waktu'
                      ? Colors.green
                      : widget.history.status == 'Izin'
                          ? Colors.orange
                          : Colors.red,
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  value: widget.history.clockIn ?? '-',
                  icon: Icons.login,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildTimeCard(
                  value: widget.history.clockOut ?? '-',
                  icon: Icons.logout,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
