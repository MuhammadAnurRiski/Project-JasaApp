import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../firebase/firebase_options.dart';


class FcmManager {
  static final FcmManager _instance = FcmManager._();
  factory FcmManager() => _instance;
  FcmManager._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  final _dio = ApiClient().dio;

  static void Function(String type, Map<String, String> data)? onNotificationTap;
  static void Function(RemoteMessage message)? onForegroundMessage;

  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}
  }

  Future<void> initialize() async {
    await _requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannel();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    final token = await _messaging.getToken();
    developer.log('[FCM] Token: ${token ?? 'NULL'}');
    if (token != null) {
      await _registerDevice(token);
    }

    _messaging.onTokenRefresh.listen((token) {
      developer.log('[FCM] Token refresh');
      _registerDevice(token);
    });

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 2), () {
        _onNotificationTapMessage(initialMessage);
      });
    }
  }

  Future<void> _requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotif.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        developer.log('[FCM] Android notification permission: ${granted ?? false}');
      } else {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      developer.log('[FCM] Error request permission: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin = _localNotif.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'jasaku_channel',
          'Jasaku Notifications',
          description: 'Notifikasi Jasaku',
          importance: Importance.high,
        ),
      );
    } catch (e) {
      developer.log('[FCM] Error create channel: $e');
    }
  }

  Future<void> _registerDevice(String token) async {
    try {
      final response = await _dio.post(ApiEndpoints.registerDevice, data: {
        'fcmToken': token,
        'deviceType': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      });
      developer.log('[FCM] Device registered: ${response.statusCode}');
    } catch (e) {
      developer.log('[FCM] Device register gagal: $e');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Jasaku';
    final body = message.notification?.body ?? '';
    final data = message.data;
    final payload = jsonEncode(data);

    const androidDetails = AndroidNotificationDetails(
      'jasaku_channel',
      'Jasaku Notifications',
      channelDescription: 'Notifikasi Jasaku',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );

    FcmManager.onForegroundMessage?.call(message);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = Map<String, String>.from(
        jsonDecode(response.payload!) as Map,
      );
      _handleNotificationTap(data);
    } catch (_) {}
  }

  void _onNotificationTapMessage(RemoteMessage message) {
    final data = Map<String, String>.from(message.data);
    _handleNotificationTap(data);
  }

  void _handleNotificationTap(Map<String, String> data) {
    final type = data['type'] ?? '';
    onNotificationTap?.call(type, data);
  }
}
