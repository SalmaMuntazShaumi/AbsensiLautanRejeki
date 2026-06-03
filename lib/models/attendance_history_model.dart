// models/attendance_history_model.dart
class AttendanceHistoryModel {
  final int? id;
  final String? date;
  final String? status;
  final String? clockIn;
  final String? clockOut;
  final String? clockInPhoto;
  final String? clockOutPhoto;
  final String? earlyOutReason;

  AttendanceHistoryModel({
    this.id,
    this.date,
    this.status,
    this.clockIn,
    this.clockOut,
    this.clockInPhoto,
    this.clockOutPhoto,
    this.earlyOutReason,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id:             json['id'],
      date:           json['date'],
      status:         json['status'],
      clockIn:        json['clock_in'],
      clockOut:       json['clock_out'],
      clockInPhoto:   json['clock_in_photo'],
      clockOutPhoto:  json['clock_out_photo'],
      earlyOutReason: json['early_out_reason'],
    );
  }
}