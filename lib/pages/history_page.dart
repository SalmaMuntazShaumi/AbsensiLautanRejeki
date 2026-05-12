import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lautanrejeki/models/attendance_history_model.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  bool isLoading = true;
  List<AttendanceHistoryModel> histories = [];

  @override
  void initState() {
    super.initState();
    fetchHistory(); // async-safe
  }

  Future<void> fetchHistory() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await _attendanceRepository.fetchAttendanceHistory(token);

      setState(() {
        histories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  String formattedDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    try {
      final dateTime = DateTime.parse(date);

      final result = DateFormat(
        'EEEE, dd MMMM yyyy',
        'id_ID',
      ).format(dateTime);

      debugPrint('FORMATTED DATE: $result');

      return result;
    } catch (e) {
      debugPrint('ERROR FORMAT DATE: $e');
      return '-';
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
          'Riwayat Absensi',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : histories.isEmpty
          ? const Center(child: Text('No attendance history'))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final history = histories[index];

          debugPrint('DATE FROM API: ${history.date}');

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
                Text(
                  formattedDate(history.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeCard(
                        title: 'Clock In',
                        value: history.clockIn ?? '-',
                        icon: Icons.login,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeCard(
                        title: 'Clock Out',
                        value: history.clockOut ?? '-',
                        icon: Icons.logout,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}