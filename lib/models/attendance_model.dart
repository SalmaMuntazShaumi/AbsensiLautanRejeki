class AttendanceModel {
  final String? checkOutPhoto;
  final String? checkInPhoto;
  final String? clockIn;
  final String? clockOut;
  final String? status;
  final String? earlyOutReason;

  AttendanceModel({
    this.clockIn,
    this.clockOut,
    this.status,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.earlyOutReason,
  });

  factory AttendanceModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AttendanceModel(
      clockIn: json['check_in'],
      clockOut: json['check_out'],
      status: json['status'],
      checkInPhoto: json['check_in_photo'],
      checkOutPhoto: json['check_out_photo'],
      earlyOutReason: json['early_out_reason'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'check_in': clockIn,
      'check_out': clockOut,
      'status': status,
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'early_out_reason': earlyOutReason,
    };
  }

  AttendanceModel copyWith({
    String? clockIn,
    String? clockOut,
    String? status,
    String? checkInPhoto,
    String? checkOutPhoto,
    String? earlyOutReason,
  }) {

    return AttendanceModel(
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      checkInPhoto: checkInPhoto ?? this.checkInPhoto,
      checkOutPhoto: checkOutPhoto ?? this.checkOutPhoto,
      earlyOutReason:
      earlyOutReason ?? this.earlyOutReason,
    );
  }
}