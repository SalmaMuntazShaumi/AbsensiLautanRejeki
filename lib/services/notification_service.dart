
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lautanrejeki/repositories/attendance_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  static const String clockInTaskId = 'clock_in_reminder';
  static const String clockOutTaskId = 'clock_out_reminder';

  // Flag untuk tracking notification yang sudah dikirim hari ini
  bool _clockInNotificationSent = false;
  bool _clockOutNotificationSent = false;

  Future<void> initNotification() async {
    try {
      // Initialize local notifications dulu
      await _initLocalNotifications();

      // Initialize Firebase Messaging
      try {
        await Firebase.initializeApp();
      } catch (e) {
        print('Firebase already initialized: $e');
      }

      // Request permission untuk iOS
      NotificationSettings settings =
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      // Get FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fcmToken');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle notification tap
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((message) => _handleNotificationTap(message));

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Setup background tasks untuk reminder
      await _setupBackgroundTasks();

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification clicked: ${response.payload}');
        }, settings: initializationSettings,
      );

      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              sound: RawResourceAndroidNotificationSound('notification'),
              playSound: true,
            ),
          );
        }
      }
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    try {
      await Firebase.initializeApp();
      print('Handling a background message: ${message.messageId}');
      _instance._handleRemoteMessage(message);
    } catch (e) {
      print('Error in background handler: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      print('Got a message in foreground');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        await _showLocalNotification(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      print('Error handling foreground message: $e');
    }
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    try {
      print('Handling remote message');
      if (message.notification != null) {
        await _showLocalNotification(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      print('Error handling remote message: $e');
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage? message) async {
    if (message != null) {
      print('Notification tapped: ${message.data}');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription:
        'This channel is used for important notifications',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: DateTime.now().millisecond % 10000,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  Future<void> _setupBackgroundTasks() async {
    try {
      // Initialize Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // Cancel existing tasks
      await Workmanager().cancelAll();

      // Schedule clock-in reminder setiap jam 9:00
      await Workmanager().registerPeriodicTask(
        clockInTaskId,
        'clockInReminder',
        frequency: const Duration(hours: 24),
        initialDelay: _getDelayToClock(9, 0),
        constraints: Constraints(
          requiresDeviceIdle: false,
          requiresCharging: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );

      // Schedule clock-out reminder setiap jam 18:00
      await Workmanager().registerPeriodicTask(
        clockOutTaskId,
        'clockOutReminder',
        frequency: const Duration(hours: 24),
        initialDelay: _getDelayToClock(18, 0),
        constraints: Constraints(
          requiresDeviceIdle: false,
          requiresCharging: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );

      print('Background tasks initialized successfully');
    } catch (e) {
      print('Error setting up background tasks: $e');
    }
  }

  Duration _getDelayToClock(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate.difference(now);
  }

  Future<void> checkAndSendClockInReminder() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) {
        print('No token found for clock-in check');
        return;
      }

      final now = DateTime.now();

      // Check if notification sudah dikirim hari ini
      if (_clockInNotificationSent) {
        print('Clock-in notification already sent today');
        return;
      }

      if (now.hour >= 9) {
        // Cek apakah user sudah clock-in hari ini
        final attendance =
        await _attendanceRepository.getAttendanceTodayByToken(token);

        if (attendance == null || attendance['clock_in'] == null) {
          await _showLocalNotification(
            title: 'Reminder Clock In',
            body:
            'Anda belum melakukan clock-in. Sudah jam ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          );
          _clockInNotificationSent = true;
        }
      }
    } catch (e) {
      print('Error checking clock-in reminder: $e');
    }
  }

  Future<void> checkAndSendClockOutReminder() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) {
        print('No token found for clock-out check');
        return;
      }

      final now = DateTime.now();

      // Check if notification sudah dikirim hari ini
      if (_clockOutNotificationSent) {
        print('Clock-out notification already sent today');
        return;
      }

      if (now.hour >= 18) {
        // Cek apakah user sudah clock-out hari ini
        final attendance =
        await _attendanceRepository.getAttendanceTodayByToken(token);

        if (attendance != null && attendance['clock_in'] != null) {
          if (attendance['clock_out'] == null) {
            await _showLocalNotification(
              title: 'Reminder Clock Out',
              body:
              'Anda belum melakukan clock-out. Sudah jam ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
            );
            _clockOutNotificationSent = true;
          }
        }
      }
    } catch (e) {
      print('Error checking clock-out reminder: $e');
    }
  }

  Future<void> resetDailyNotifications() async {
    _clockInNotificationSent = false;
    _clockOutNotificationSent = false;
  }

  void disposeNotifications() {
    Workmanager().cancelByTag(clockInTaskId);
    Workmanager().cancelByTag(clockOutTaskId);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      final notificationService = NotificationService();

      if (task == 'clockInReminder') {
        print('Clock-in reminder task triggered');
        await notificationService.checkAndSendClockInReminder();
      } else if (task == 'clockOutReminder') {
        print('Clock-out reminder task triggered');
        await notificationService.checkAndSendClockOutReminder();
      }

      return true;
    } catch (e) {
      print('Error in background task: $e');
      return false;
    }
  });
}