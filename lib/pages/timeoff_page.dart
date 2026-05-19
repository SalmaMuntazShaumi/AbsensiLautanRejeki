import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lautanrejeki/repositories/timeoff_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class TimeOffPage extends StatefulWidget {
  const TimeOffPage({super.key});

  @override
  State<TimeOffPage> createState() => _TimeOffPageState();
}

class _TimeOffPageState extends State<TimeOffPage> {
  final TimeOffRepository _repository = TimeOffRepository();

  final TextEditingController reasonController =
  TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String selectedType = 'Cuti Sakit';

  bool isLoading = false;

  final List<String> leaveTypes = [
    'Cuti Sakit',
    'Cuti Tahunan',
    'Cuti Besar',
    'Cuti Melahirkan',
    'Cuti Lainnya',
  ];

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;

        if (endDate != null &&
            endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tolong pilih tanggal mulai terlebih dahulu',
          ),
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: startDate!,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> submitTimeOff() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tolong pilih tanggal mulai dan tanggal selesai',
          ),
        ),
      );
      return;
    }

    if (reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alasan tidak boleh kosong',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final token = await SessionService.getToken();

      if (token == null) return;

      await _repository.createTimeOff(
        token: token,
        type: selectedType,
        startDate:
        DateFormat('yyyy-MM-dd').format(startDate!),
        endDate:
        DateFormat('yyyy-MM-dd').format(endDate!),
        reason: reasonController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cuti berhasil diajukan! Menunggu persetujuan dari atasan.',
          ),
        ),
      );

      setState(() {
        reasonController.clear();
        startDate = null;
        endDate = null;
        selectedType = 'Cuti Sakit';
      });
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

  Widget buildDateField({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

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
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value != null
                      ? DateFormat(
                    'dd MMM yyyy',
                  ).format(value)
                      : 'Pilih tanggal',

                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Icon(
              Icons.calendar_month,
              color: AppColors.primaryColor,
            ),
          ],
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
          'Pengajuan Cuti',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushNamed(context, '/timeoff_history');
              },
              icon: Icon(CupertinoIcons.calendar),
            iconSize: 26,
            color: AppColors.secondaryColor,
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Jenis Cuti',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField(
                    value: selectedType,

                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                      AppColors.primaryColor.withOpacity(0.05),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: leaveTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  buildDateField(
                    title: 'Tanggal Mulai',
                    value: startDate,
                    onTap: pickStartDate,
                  ),

                  const SizedBox(height: 16),

                  buildDateField(
                    title: 'Tanggal Selesai',
                    value: endDate,
                    onTap: pickEndDate,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Alasan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: reasonController,
                    maxLines: 5,

                    decoration: InputDecoration(
                      hintText:
                      'Jelaskan alasan cuti anda di sini...',

                      filled: true,
                      fillColor:
                      AppColors.primaryColor.withOpacity(0.05),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,

                    child: ElevatedButton(
                      onPressed:
                      isLoading
                          ? null
                          : submitTimeOff,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryColor,
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),

                      child:
                      isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Ajukan Cuti',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
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
}