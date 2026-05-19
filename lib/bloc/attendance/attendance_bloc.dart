import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/attendance_model.dart';

import '../../repositories/attendance_repository.dart';

import '../../services/attendance_service.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc
    extends Bloc<AttendanceEvent, AttendanceState> {

  final AttendanceRepository repository;

  AttendanceModel attendance =
  AttendanceModel();

  AttendanceBloc(this.repository)
      : super(AttendanceInitial()) {

    on<GetAttendanceToday>(
      _onGetAttendanceToday,
    );

    on<VerifyLocationRequested>(
      _onVerifyLocation,
    );

    on<ClockInRequested>(
      _onClockIn,
    );

    on<ClockOutRequested>(
      _onClockOut,
    );
  }

  // =========================
  // VERIFY LOCATION
  // =========================
  Future<void> _onVerifyLocation(
      VerifyLocationRequested event,
      Emitter<AttendanceState> emit,
      ) async {

    emit(AttendanceLoading());

    try {

      final isWithinRadius =
      await AttendanceService
          .verifyOfficeRadius();

      final distance =
      await AttendanceService
          .getOfficeDistance();

      if (isWithinRadius) {

        emit(
          LocationVerified(
            isWithinRadius: true,
            distance: distance,
          ),
        );

      } else {

        emit(
          LocationOutOfRadius(
            distance: distance,
          ),
        );
      }

    } catch (e) {

      emit(
        AttendanceFailure(
          e.toString(),
        ),
      );
    }
  }

  // =========================
  // CLOCK IN
  // =========================
  Future<void> _onClockIn(
      ClockInRequested event,
      Emitter<AttendanceState> emit,
      ) async {

    emit(AttendanceLoading());

    try {

      final response =
      await repository.clockIn(

        token: event.token,
        photo: event.photo,

      );

      attendance = attendance.copyWith(

        clockIn: response.clockIn,
        status: response.status,
        clockInPhoto: response.clockInPhoto,

      );

      emit(
        AttendanceSuccess(
          'Clock In Success',
        ),
      );

      emit(
        AttendanceLoaded(
          attendance,
        ),
      );

    } catch (e) {

      emit(
        AttendanceFailure(
          e.toString(),
        ),
      );
    }
  }

  Future<void> _onGetAttendanceToday(
      GetAttendanceToday event,
      Emitter<AttendanceState> emit,
      ) async {

    try {

      emit(AttendanceLoading());

      attendance =
      await repository.getTodayAttendance(
        token: event.token,
      );

      emit(
        AttendanceLoaded(attendance),
      );

    } catch (e) {

      emit(
        AttendanceFailure(
          e.toString(),
        ),
      );
    }
  }

  // =========================
  // CLOCK OUT
  // =========================
  Future<void> _onClockOut(
      ClockOutRequested event,
      Emitter<AttendanceState> emit,
      ) async {

    emit(AttendanceLoading());

    try {
      await repository.clockOut(
        token: event.token,
        reason: event.reason,
      );

      final now =
      AttendanceService.getCurrentTime();

      attendance = attendance.copyWith(
        clockOut: now,
        earlyOutReason: event.reason,
      );

      emit(
        AttendanceLoaded(attendance),
      );

      emit(
        AttendanceSuccess(
          'Clock Out Success',
        ),
      );

      emit(
        AttendanceLoaded(attendance),
      );
    } catch (e) {

      emit(
        AttendanceFailure(
          e.toString(),
          attendance: attendance,
        ),
      );
    }
  }
}