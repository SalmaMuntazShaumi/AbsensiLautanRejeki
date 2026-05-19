import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lautanrejeki/repositories/timeoff_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class TimeOffHistoryPage extends StatefulWidget {
  const TimeOffHistoryPage({super.key});

  @override
  State<TimeOffHistoryPage> createState() =>
      _TimeOffHistoryPageState();
}

class _TimeOffHistoryPageState
    extends State<TimeOffHistoryPage> {
  final TimeOffRepository timeOffRepository =
  TimeOffRepository();

  bool isLoading = true;

  List<dynamic> timeOffs = [];

  @override
  void initState() {
    super.initState();

    fetchTimeOff();
  }

  Future<void> fetchTimeOff() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await SessionService.getToken();

      if (token == null) return;

      final data = await timeOffRepository.getTimeOff(
        token: token,
      );

      setState(() {
        timeOffs = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memuat riwayat cuti',
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return Colors.green;

      case 'ditolak':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  String formatDate(String date) {
    try {
      return DateFormat(
        'dd MMM yyyy',
        'id_ID',
      ).format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildTimeOffCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
              Text(
                item['type'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),

              buildStatusBadge(
                item['status'] ?? 'Menunggu Konfirmasi',
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: AppColors.primaryColor,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  '${formatDate(item['start_date'])} - ${formatDate(item['end_date'])}',

                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color:
              AppColors.primaryColor.withOpacity(0.05),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Text(
              item['reason'] ?? '-',
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
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
          'Riwayat Cuti',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body:
      isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : timeOffs.isEmpty
          ? const Center(
        child: Text(
          'Belum ada pengajuan cuti',
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchTimeOff,

        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: timeOffs.length,

          itemBuilder: (context, index) {
            return buildTimeOffCard(
              timeOffs[index],
            );
          },
        ),
      ),
    );
  }
}