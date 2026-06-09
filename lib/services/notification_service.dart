import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  static const int clockInNotifId = 1;
  static const int clockOutNotifId = 2;

  // ─── INIT ─────────────────────────────────────────────────────────────────

  Future<void> initNotification() async {
    _initTimezone();
    await _initLocalNotification();
    await _initFirebaseMessaging();
    await _requestExactAlarmPermission();
    await _requestBatteryOptimization();

    print('=== STARTING SCHEDULE ===');
    await scheduleClockInReminder();
    print('=== CLOCK IN DONE ===');
    await scheduleClockOutReminder();
    print('=== CLOCK OUT DONE ===');
  }

  void _initTimezone() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  Future<void> _initLocalNotification() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // v17: positional argument
    // Di initNotification, setelah notif muncul, jadwalkan ulang
    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification clicked: ${response.payload}');
        // Reschedule untuk hari berikutnya (skip Minggu otomatis)
        await scheduleClockInReminder();
        await scheduleClockOutReminder();
      },
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Used for important notifications',
        importance: Importance.max,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _requestBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    print('Battery optimization status: $status');

    if (!status.isGranted) {
      final result = await Permission.ignoreBatteryOptimizations.request();
      print('Battery optimization request result: $result');
    }
  }

  Future<void> _initFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  // ─── SCHEDULE ─────────────────────────────────────────────────────────────

  Future<void> scheduleClockInReminder() async {
    try {
      // v17: positional argument
      await _flutterLocalNotificationsPlugin.cancel(clockInNotifId);

      final scheduledDate = _nextInstanceOfTime(9, 0);

      print('Clock-in scheduling at: $scheduledDate');

      // v17: semua positional untuk 5 arg pertama
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        clockInNotifId,
        'Reminder Clock In',
        'Jangan lupa clock in hari ini',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            icon: '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Clock-in zonedSchedule SUCCESS');
    } catch (e) {
      print('Clock-in zonedSchedule ERROR: $e');
    }
  }

  Future<void> scheduleClockOutReminder() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(clockOutNotifId);

      final scheduledDate = _nextInstanceOfTime(18, 0);
      print('Clock-out scheduling at: $scheduledDate');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        clockOutNotifId,
        'Reminder Clock Out',
        'Jangan lupa clock out sebelum pulang',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            icon: '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Clock-out zonedSchedule SUCCESS');
    } catch (e) {
      print('Clock-out zonedSchedule ERROR: $e');
    }
  }
  // ─── CANCEL JIKA SUDAH CLOCK IN/OUT ───────────────────────────────────────

  Future<void> cancelClockInIfAlreadyClockedIn(String token) async {
    try {
      final attendance =
      await _attendanceRepository.getAttendanceTodayByToken(token);

      if (attendance != null && attendance['clock_in'] != null) {
        await _flutterLocalNotificationsPlugin.cancel(clockInNotifId);
        print('Clock-in notif cancelled — user sudah clock-in');
      }
    } catch (e) {
      print('Error cancel clock-in notif: $e');
    }
  }

  Future<void> cancelClockOutIfAlreadyClockedOut(String token) async {
    try {
      final attendance =
      await _attendanceRepository.getAttendanceTodayByToken(token);

      if (attendance != null && attendance['clock_out'] != null) {
        await _flutterLocalNotificationsPlugin.cancel(clockOutNotifId);
        print('Clock-out notif cancelled — user sudah clock-out');
      }
    } catch (e) {
      print('Error cancel clock-out notif: $e');
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // ✅ Skip hari Minggu (DateTime.sunday = 7)
    while (scheduled.weekday == DateTime.sunday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ─── FIREBASE HANDLERS ────────────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification == null) return;

    await _showLocalNotification(
      title: message.notification!.title ?? 'Notifikasi',
      body: message.notification!.body ?? '',
      payload: message.data.toString(),
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification opened: ${message.data}');
  }

  // ─── SHOW NOTIFICATION ────────────────────────────────────────────────────

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          icon: '@mipmap/launcher_icon',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // ─── CANCEL ALL ───────────────────────────────────────────────────────────

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}