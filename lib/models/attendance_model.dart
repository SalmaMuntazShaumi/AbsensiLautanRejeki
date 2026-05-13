class AttendanceModel {
  final String? clockOutPhoto;
  final String? clockInPhoto;
  final String? clockIn;
  final String? clockOut;
  final String? status;
  final String? earlyOutReason;

  AttendanceModel({
    this.clockIn,
    this.clockOut,
    this.status,
    this.clockInPhoto,
    this.clockOutPhoto,
    this.earlyOutReason,
  });

  factory AttendanceModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AttendanceModel(
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      status: json['status'],
      clockInPhoto: json['clock_in_photo'],
      clockOutPhoto: json['clock_out_photo'],
      earlyOutReason: json['early_out_reason'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'clock_in': clockIn,
      'clock_out': clockOut,
      'status': status,
      'clock_in_photo': clockInPhoto,
      'clock_out_photo': clockOutPhoto,
      'early_out_reason': earlyOutReason,
    };
  }

  AttendanceModel copyWith({
    String? clockIn,
    String? clockOut,
    String? status,
    String? clockInPhoto,
    String? clockOutPhoto,
    String? earlyOutReason,
  }) {

    return AttendanceModel(
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      clockInPhoto: clockInPhoto ?? this.clockInPhoto,
      clockOutPhoto: clockOutPhoto ?? this.clockOutPhoto,
      earlyOutReason:
      earlyOutReason ?? this.earlyOutReason,
    );
  }
}