import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';

import '../pages/camera_page.dart';
import '../services/attendance_service.dart';

import '../src/colors.dart';

import 'realtime_clock.dart';

class CustomAbsentCard extends StatelessWidget {
  final String token;

  const CustomAbsentCard({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
        AttendanceBloc,
        AttendanceState>(

      // =========================
      // LISTENER
      // =========================
      listener: (context, state) {

        // ❌ ERROR
        if (state is AttendanceFailure) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }

        // ✅ SUCCESS
        if (state is AttendanceSuccess) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ❌ OUTSIDE OFFICE RADIUS
        if (state is LocationOutOfRadius) {

          _showLocationErrorDialog(
            context,
            state.distance,
          );
        }

        // ✅ LOCATION VERIFIED
        if (state is LocationVerified &&
            state.isWithinRadius) {

          _openCameraForClockIn(context);
        }
      },

      // =========================
      // BUILDER
      // =========================
      builder: (context, state) {

        String clockIn = '--:--';

        String clockOut = '--:--';

        String status = '';

        bool hasClockedIn = false;

        bool hasClockedOut = false;

        AttendanceLoaded? loadedState;

        if (state is AttendanceLoaded) {
          loadedState = state;
        }

        if (state is AttendanceFailure &&
            state.attendance != null) {

          loadedState = AttendanceLoaded(
            state.attendance!,
          );
        }

        if (loadedState != null) {

          clockIn = _formatTime(
            loadedState.attendance.clockIn,
          );

          clockOut = _formatTime(
            loadedState.attendance.clockOut,
          );

          status =
              loadedState.attendance.status
                  ?? '';

          hasClockedIn =
              loadedState.attendance.clockIn
                  != null;

          hasClockedOut =
              loadedState.attendance.clockOut
                  != null;
        }

        return Container(

          margin: const EdgeInsets.only(
            top: 20,
          ),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius:
            BorderRadius.circular(8),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // CLOCK
              const RealtimeClock(),

              const SizedBox(height: 16),

              // CLOCK IN / OUT
              Row(
                children: [

                  _timeColumn(
                    'Clock-in',
                    clockIn,
                  ),

                  const SizedBox(width: 40),

                  const Expanded(
                    child: Divider(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 40),

                  _timeColumn(
                    'Clock-out',
                    clockOut,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // STATUS
              hasClockedIn
                  ? Text(
                'Status: $status',

                style:
                const TextStyle(
                  color:
                  Colors.white,
                ),
              )
                  : const SizedBox.shrink(),

              const SizedBox(height: 16),

              // BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    backgroundColor:
                    AppColors.secondaryColor,
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),

                  onPressed:
                  state
                  is AttendanceLoading
                      ? null
                      : hasClockedOut
                      ? null
                      : () {

                    if (!hasClockedIn) {

                      _handleClockInFlow(
                        context,
                      );

                    } else {

                      _handleClockOutFlow(
                        context,
                      );
                    }
                  },

                  child:
                  state is AttendanceLoading
                      ? const SizedBox(

                    width: 20,
                    height: 20,

                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(

                    !hasClockedIn
                        ? 'Clock In'
                        : hasClockedOut
                        ? 'Completed'
                        : 'Clock Out',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // TIME COLUMN
  // =========================
  Widget _timeColumn(
      String title,
      String time,
      ) {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          time,

          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatTime(String? time) {

    if (time == null || time.isEmpty) {
      return '--:--';
    }

    try {

      // kalau format datetime penuh
      final dateTime = DateTime.parse(time).toLocal();

      return
        '${dateTime.hour.toString().padLeft(2, '0')}:'
            '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {

      // kalau formatnya udah HH:mm:ss
      if (time.length >= 8) {
        return time.substring(0, 8);
      }

      return time;
    }
  }

  // =========================
  // CLOCK IN FLOW
  // =========================
  void _handleClockInFlow(
      BuildContext context,
      ) {

    context.read<AttendanceBloc>().add(
      VerifyLocationRequested(),
    );
  }

  // =========================
  // CLOCK OUT FLOW
  // =========================
  void _handleClockOutFlow(
      BuildContext context,
      ) {

    // EARLY OUT
    if (AttendanceService.isEarlyOut()) {

      _showEarlyOutDialog(context);

    }

    // NORMAL CLOCK OUT
    else {

      context.read<AttendanceBloc>().add(

        ClockOutRequested(
          token: token,
        ),
      );
    }
  }

  // =========================
  // LOCATION ERROR DIALOG
  // =========================
  void _showLocationErrorDialog(
      BuildContext context,
      double distance,
      ) {

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (_) => AlertDialog(

        title: const Text(
          'Location Verification Failed',
        ),

        content: Text(
          'You are '
              '${distance.toStringAsFixed(2)} '
              'meters away from the office.\n\n'
              'You need to be within '
              '100 meters to clock in.',
        ),

        actions: [

          ElevatedButton(

            onPressed: () {

              Navigator.pop(context);
            },

            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // =========================
  // EARLY OUT DIALOG
  // =========================
  void _showEarlyOutDialog(
      BuildContext context,
      ) {

    final reasonController =
    TextEditingController();

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (_) => AlertDialog(

        title: const Text(
          'Early Out',
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            const Text(
              'Anda clock-out kurang dari jam 16:50.',
            ),

            const SizedBox(height: 16),

            TextField(
              controller: reasonController,

              maxLines: 3,

              decoration: InputDecoration(
                hintText:
                'Mohon masukkan alasan early out Anda...',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);
            },

            child: const Text('Batal'),
          ),

          ElevatedButton(

            onPressed: () {

              if (reasonController.text.trim().isEmpty) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(
                    content: Text(
                      'Alasan early out wajib diisi',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );

                return;
              }

              Navigator.pop(context);

              context.read<AttendanceBloc>().add(
                ClockOutRequested(
                  token: token,
                  reason: reasonController.text,
                ),
              );
            },

            child: const Text(
              'Kirim',
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // OPEN CAMERA CLOCK IN
  // =========================
  void _openCameraForClockIn(
      BuildContext context,
      ) {

    Navigator.push<Map<String, dynamic>>(

      context,

      MaterialPageRoute(

        builder: (_) => CameraPage(
          clockType: 'in',
          token: token,
        ),
      ),

    ).then((result) {

      print('CAMERA RESULT: $result');

      if (result != null) {

        context.read<AttendanceBloc>().add(

          ClockInRequested(
            token: result['token'],
            photo: result['photo'],
          ),
        );
      }
    });
  }

  // =========================
  // OPEN CAMERA CLOCK OUT
  // =========================
  void _openCameraForClockOut(
      BuildContext context,
      {String? reason}
      ) {

    Navigator.push<Map<String, dynamic>>(

      context,

      MaterialPageRoute(

        builder: (_) => CameraPage(
          clockType: 'out',
          token: token,
          earlyOutReason: reason,
        ),
      ),

    ).then((result) {

      print('CLOCK OUT RESULT: $result');

      if (result != null) {

        context.read<AttendanceBloc>().add(

          ClockOutRequested(
            token: result['token'],
            reason: result['reason'],
          ),
        );
      }
    });
  }
}