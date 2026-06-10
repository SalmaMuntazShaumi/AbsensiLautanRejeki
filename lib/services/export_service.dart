import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportAttendanceToExcel({
    required List<Map<String, dynamic>> data,
    required String reportType,
    String? selectedDate,
    String? selectedWeek,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    final excel = Excel.createExcel();

    // Hapus default sheet
    excel.delete('Sheet1');

    // Buat sheet baru
    excel['Absensi'];
    final sheet = excel.sheets['Absensi']!;

    // ─── HEADERS ──────────────────────────────────────────────────────────
    final headers = [
      'No',
      'Nama',
      'Tanggal',
      'Jam Masuk',
      'Jam Keluar',
      'Status',
      'Keterangan',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1E88E5'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // ─── DATA ROWS ────────────────────────────────────────────────────────
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final row = i + 1;

      final rowData = [
        '${i + 1}',
        item['nama']?.toString() ?? '-',
        item['date']?.toString() ?? '-',
        item['clock_in']?.toString() ?? '-',
        item['clock_out']?.toString() ?? '-',
        _translateStatus(item['status']),
        item['early_out_reason']?.toString() ?? '-',
      ];

      final bgColor = row % 2 == 0
          ? ExcelColor.fromHexString('#F5F5F5')
          : ExcelColor.fromHexString('#FFFFFF');

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row),
        );
        cell.value = TextCellValue(rowData[j]);
        cell.cellStyle = CellStyle(
          backgroundColorHex: bgColor,
          horizontalAlign: j == 1
              ? HorizontalAlign.Left   // Nama left-align
              : HorizontalAlign.Center,
        );
      }
    }

    // ─── COLUMN WIDTHS ────────────────────────────────────────────────────
    sheet.setColumnWidth(0, 5);   // No
    sheet.setColumnWidth(1, 25);  // Nama
    sheet.setColumnWidth(2, 15);  // Tanggal
    sheet.setColumnWidth(3, 12);  // Jam Masuk
    sheet.setColumnWidth(4, 12);  // Jam Keluar
    sheet.setColumnWidth(5, 15);  // Status
    sheet.setColumnWidth(6, 30);  // Keterangan

    // ─── SAVE & SHARE ─────────────────────────────────────────────────────
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Gagal membuat file Excel');

    final dir = await getTemporaryDirectory();
    final filename = _buildFilename(
      reportType,
      selectedDate,
      selectedWeek,
      selectedMonth,
      selectedYear,
    );
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    await Share.shareFiles(
      [file.path],
      subject: 'Laporan Absensi - $filename',
      mimeTypes: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  static String _translateStatus(dynamic status) {
    switch (status?.toString()) {
      case 'on_time': return 'Tepat Waktu';
      case 'late':    return 'Terlambat';
      case 'absent':  return 'Tidak Hadir';
      case 'leave':   return 'Izin';
      default:        return status?.toString() ?? '-';
    }
  }

  static String _buildFilename(
      String reportType,
      String? selectedDate,
      String? selectedWeek,
      String? selectedMonth,
      String? selectedYear,
      ) {
    final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    switch (reportType) {
      case 'daily':   return 'Absensi_${selectedDate ?? now}.xlsx';
      case 'weekly':  return 'Absensi_${selectedWeek ?? now}.xlsx';
      case 'monthly': return 'Absensi_${selectedMonth ?? now}.xlsx';
      case 'yearly':  return 'Absensi_${selectedYear ?? now}.xlsx';
      default:        return 'Absensi_$now.xlsx';
    }
  }
}