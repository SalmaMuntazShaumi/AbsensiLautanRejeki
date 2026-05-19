import '../../models/attendance_model.dart';

abstract class AttendanceState {}

class AttendanceInitial
    extends AttendanceState {}

class AttendanceLoading
    extends AttendanceState {}

class LocationVerified
    extends AttendanceState {

  final bool isWithinRadius;
  final double distance;

  LocationVerified({
    required this.isWithinRadius,
    required this.distance,
  });
}

class LocationOutOfRadius
    extends AttendanceState {

  final double distance;

  LocationOutOfRadius({
    required this.distance,
  });
}

class AttendanceLoaded
    extends AttendanceState {

  final AttendanceModel attendance;

  AttendanceLoaded(this.attendance);
}

class AttendanceSuccess
    extends AttendanceState {

  final String message;

  AttendanceSuccess(this.message);
}

class AttendanceFailure extends AttendanceState {

  final String error;

  final AttendanceModel? attendance;

  AttendanceFailure(
      this.error, {
        this.attendance,
      });
}