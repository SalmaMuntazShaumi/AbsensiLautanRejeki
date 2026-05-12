abstract class AttendanceEvent {}

class VerifyLocationRequested
    extends AttendanceEvent {}

class ClockInRequested
    extends AttendanceEvent {

  final String token;
  final String photo;

  ClockInRequested({
    required this.token,
    required this.photo,
  });
}

class ClockOutRequested
    extends AttendanceEvent {

  final String token;
  final String photo;
  final String? reason;

  ClockOutRequested({
    required this.token,
    required this.photo,
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