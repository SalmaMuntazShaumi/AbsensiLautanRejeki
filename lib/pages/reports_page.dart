import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';
import 'package:lautanrejeki/services/export_service.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AttendanceRepository _repo = AttendanceRepository();

  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = false;
  String _token = '';
  String _searchQuery = '';

  // Filter state
  String _reportType = 'daily';
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  String get _currentWeek {
    final now = DateTime.now();
    final weekNum = ((now.difference(DateTime(now.year, 1, 1)).inDays +
        DateTime(now.year, 1, 1).weekday) / 7).ceil();
    return '${now.year}-W${weekNum.toString().padLeft(2, '0')}';
  }
  String _selectedMonth = DateTime.now().toIso8601String().substring(0, 7);
  String _selectedYear = DateTime.now().year.toString();

  late String _selectedWeek;


  @override
  void initState() {
    super.initState();
    _selectedWeek = _currentWeek;
    _init();
  }

  Future<void> _init() async {
    final token = await SessionService.getToken();
    if (token == null) return;
    _token = token;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.fetchAllAttendanceHistory(
        _token,
        date: _reportType == 'daily' ? _selectedDate : null,
        week: _reportType == 'weekly' ? _selectedWeek : null,
        month: _reportType == 'monthly' ? _selectedMonth : null,
        year: _reportType == 'yearly' ? _selectedYear : null,
      );
      setState(() {
        _data = data;
        _applySearch();
      });
    } catch (e) {
      _showSnackbar('Gagal memuat data: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_data);
    } else {
      _filtered = _data.where((item) =>
      item['nama']?.toString().toLowerCase()
          .contains(_searchQuery.toLowerCase()) ?? false,
      ).toList();
    }
  }

  Future<void> _exportExcel() async {
    if (_data.isEmpty) {
      _showSnackbar('Tidak ada data untuk di-export', Colors.orange);
      return;
    }
    try {
      await ExportService.exportAttendanceToExcel(
        data: _data,
        reportType: _reportType,
        selectedDate: _selectedDate,
        selectedWeek: _selectedWeek,
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
      );
    } catch (e) {
      _showSnackbar('Gagal export: $e', Colors.red);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _translateStatus(String? status) {
    switch (status) {
      case 'on_time': return 'Tepat Waktu';
      case 'late':    return 'Terlambat';
      case 'absent':  return 'Tidak Hadir';
      case 'leave':   return 'Izin';
      default:        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'on_time': return Colors.green;
      case 'late':    return Colors.orange;
      case 'absent':  return Colors.red;
      case 'leave':   return Colors.blue;
      default:        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Laporan Absensi',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primaryColor),
            tooltip: 'Export Excel',
            onPressed: _exportExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildSearchBar(),
          _buildSummaryBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final dayOfYear = int.parse(DateFormat('D').format(d));
    return ((dayOfYear - d.weekday + 10) / 7).floor();
  }
  // ─── FILTER SECTION ───────────────────────────────────────────────────────

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report type tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['daily', 'weekly', 'monthly', 'yearly'].map((type) {
                final labels = {
                  'daily': 'Harian',
                  'weekly': 'Mingguan',
                  'monthly': 'Bulanan',
                  'yearly': 'Tahunan',
                };
                final isSelected = _reportType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() => _reportType = type);
                    _fetchData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labels[type]!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Date picker
          Row(
            children: [
              Expanded(child: _buildDatePicker()),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _fetchData,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Cari'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    if (_reportType == 'daily') {
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.parse(_selectedDate),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked.toIso8601String().split('T')[0];
            });
          }
        },
        child: _datePickerField(
          icon: Icons.calendar_today_rounded,
          label: 'Tanggal',
          value: _selectedDate,
        ),
      );
    }

    if (_reportType == 'weekly') {
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            helpText: 'Pilih tanggal dalam minggu yang diinginkan',
          );
          if (picked != null) {
            // Format ke ISO week: 2026-W24
            final weekNum = _getWeekNumber(picked);
            setState(() {
              _selectedWeek = '${picked.year}-W${weekNum.toString().padLeft(2, '0')}';
            });
          }
        },
        child: _datePickerField(
          icon: Icons.date_range_rounded,
          label: 'Minggu',
          value: _selectedWeek,
        ),
      );
    }

    if (_reportType == 'monthly') {
      return InkWell(
        onTap: () => _showMonthPicker(),
        child: _datePickerField(
          icon: Icons.calendar_month_rounded,
          label: 'Bulan',
          value: _selectedMonth,
        ),
      );
    }

    // yearly
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          isExpanded: true,
          items: List.generate(5, (i) {
            final year = (DateTime.now().year - i).toString();
            return DropdownMenuItem(value: year, child: Text(year));
          }),
          onChanged: (val) {
            if (val != null) setState(() => _selectedYear = val);
          },
        ),
      ),
    );
  }

  Widget _datePickerField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthPicker() async {
    final parts = _selectedMonth.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pilih Bulan'),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (ctx, i) {
              final m = i + 1;
              final isSelected = m == month;
              final monthNames = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Agu','Sep','Okt','Nov','Des'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMonth = '$year-${m.toString().padLeft(2, '0')}';
                  });
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    monthNames[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _applySearch();
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari nama karyawan...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── SUMMARY BAR ──────────────────────────────────────────────────────────

  Widget _buildSummaryBar() {
    final onTime = _data.where((d) => d['status'] == 'on_time').length;
    final late   = _data.where((d) => d['status'] == 'late').length;
    final absent = _data.where((d) => d['status'] == 'absent').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem('Total', '${_filtered.length}', Colors.blue),
          _summaryDivider(),
          _summaryItem('Tepat Waktu', '$onTime', Colors.green),
          _summaryDivider(),
          _summaryItem('Terlambat', '$late', Colors.orange),
          _summaryDivider(),
          _summaryItem('Absen', '$absent', Colors.red),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2));
  }

  // ─── CONTENT ──────────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada data',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) => _buildCard(_filtered[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final status = item['status']?.toString();
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              (item['nama']?.toString() ?? '?')[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item['date'] ?? '-',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Clock in/out
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.login_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    item['clock_in'] ?? '-',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    item['clock_out'] ?? '-',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _translateStatus(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}