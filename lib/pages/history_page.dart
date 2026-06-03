import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lautanrejeki/components/custom_history_card.dart';
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
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchHistory(); // async-safe
  }

  List<AttendanceHistoryModel> get filteredHistories {
    return histories.where((history) {
      if (history.date == null) return false;

      final date = DateTime.tryParse(history.date!);

      if (date == null) return false;

      return date.month == selectedMonth.month &&
          date.year == selectedMonth.year;
    }).toList();
  }

  Future<void> selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
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

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
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
      setState(() => isLoading = false);
      debugPrint('FETCH ERROR: $e');  // Lihat pesan error lengkapnya
      if (e is DioException) {
        debugPrint('RESPONSE: ${e.response?.data}');
        debugPrint('STATUS: ${e.response?.statusCode}');
      }
    }
  }

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: GestureDetector(
                    onTap: selectMonth,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: AppColors.primaryColor,
                              ),

                              const SizedBox(width: 12),

                              Text(
                                DateFormat(
                                  'MMMM yyyy',
                                  'id_ID',
                                ).format(selectedMonth),

                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: filteredHistories.isEmpty
                      ? const Center(child: Text('Tidak ada riwayat absensi'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredHistories.length,
                          itemBuilder: (context, index) {
                            final history = filteredHistories[index];

                            debugPrint('DATE FROM API: ${history.date}');

                            return CustomHistoryCard(history: history);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
