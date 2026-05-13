import 'dart:io';

abstract class AttendanceEvent {}

class VerifyLocationRequested
    extends AttendanceEvent {}

class ClockInRequested
    extends AttendanceEvent {

  final String token;
  final File photo;

  ClockInRequested({
    required this.token,
    required this.photo,
  });
}

class ClockOutRequested
    extends AttendanceEvent {

  final String token;
  final String? reason;

  ClockOutRequested({
    required this.token,
    this.reason,
  }); 
}

class GetAttendanceToday
    extends AttendanceEvent {

  final String token;

  GetAttendanceToday({
    required this.token,
  });
}