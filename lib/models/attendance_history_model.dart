class AttendanceHistoryModel {

  final int? id;

  final String? date;

  final String? status;

  final String? clockIn;

  final String? clockOut;

  final String? earlyOutReason;

  AttendanceHistoryModel({

    this.id,

    this.date,

    this.status,

    this.clockIn,

    this.clockOut,

    this.earlyOutReason,
  });

  factory AttendanceHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AttendanceHistoryModel(

      id: json['id'],

      date: json['date'],

      status: json['status'],

      clockIn: json['clock_in'],

      clockOut: json['clock_out'],

      earlyOutReason:
      json['early_out_reason'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'date': date,

      'status': status,

      'clock_in': clockIn,

      'clock_out': clockOut,

      'early_out_reason': earlyOutReason,
    };
  }
}