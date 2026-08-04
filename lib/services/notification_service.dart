import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pray_iafcj/data/phrases.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

///==============================================================
/// Manejador de mensajes en segundo plano.
///
/// Se ejecuta cuando el usuario tiene la app cerrada o en
/// segundo plano y llega una notificación push (FCM).
///==============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.messageId}');
}

///==============================================================
/// Servicio de notificaciones.
///
/// Se encarga de:
/// - Pedir permiso de notificaciones al sistema.
/// - Obtener el token FCM del dispositivo y guardarlo en Firestore.
/// - Programar el recordatorio diario local (oración y lectura).
///==============================================================
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;

  static const String _channelId = 'recordatorios';

  static const String _channelName = 'Recordatorios';

  static const String _channelDescription =
      'Recordatorios de oración y lectura bíblica';

  static bool _initialized = false;

  static bool _localInitialized = false;

  static String? _currentUserId;

  //============================================================
  // Solo soportamos recordatorios locales en dispositivos móviles
  // (Android, iOS y macOS). En escritorio/web se omite.
  //============================================================

  static bool get _supportsLocalNotifications {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  //============================================================
  // Inicializar notificaciones.
  //
  // Pide permiso, registra los manejadores y guarda el token
  // del dispositivo en Firestore.
  //============================================================

  static Future<void> initialize() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (_initialized && _currentUserId == userId) return;
    _currentUserId = userId;
    _initialized = true;

    await _initializeLocalNotifications();

    try {
      if (_supportsLocalNotifications) {
        try {
          await _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();
        } catch (_) {}
      }

      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensaje en primer plano: ${message.notification?.title}');
        _showPushNotification(message);
      });

      final token = await _messaging.getToken();
      await _saveToken(token);
    } catch (e) {
      print('Error al inicializar notificaciones push: $e');
    }
  }

  //============================================================
  // Actualizar el token en Firestore (por si cambia).
  //============================================================

  static Future<void> refreshToken() async {
    final token = await _messaging.getToken();
    await _saveToken(token);
  }

  //============================================================
  // Guardar el token del dispositivo en documento del
  // usuario actual dentro de Firestore.
  //============================================================

  static Future<void> _saveToken(String? token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || token == null || token.isEmpty) return;

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  //============================================================
  // Recordatorio diario programado en el dispositivo.
  //============================================================

  static Future<void> _initializeLocalNotifications() async {
    if (_localInitialized || !_supportsLocalNotifications) return;
    _localInitialized = true;

    tz.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      print('No se pudo obtener la zona horaria: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
    );
  }

  //============================================================
  // Mostrar en primer plano una notificación push (FCM).
  //============================================================

  static Future<void> _showPushNotification(RemoteMessage message) async {
    if (!_supportsLocalNotifications) return;

    final notification = message.notification;
    if (notification == null) return;

    await _initializeLocalNotifications();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title ?? 'Pray IAFCJ',
      body: notification.body ?? '',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      ),
    );
  }

  /// Programa (o reprograma) el recordatorio diario a la hora indicada.
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_supportsLocalNotifications) return;

    await _initializeLocalNotifications();

    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    try {
      await _localNotifications.zonedSchedule(
        id: _reminderId,
        title: 'Momento de Oración y Lectura',
        body: AppPhrases.phrases[Random().nextInt(AppPhrases.phrases.length)],
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Recordatorio diario programado para las $hour:$minute');
    } catch (e) {
      debugPrint('Error al programar el recordatorio: $e');
    }
  }

  /// Cancela el recordatorio diario.
  static Future<void> cancelDailyReminder() async {
    if (!_supportsLocalNotifications) return;
    await _initializeLocalNotifications();
    await _localNotifications.cancel(id: _reminderId);
    debugPrint('Recordatorio diario cancelado.');
  }
}
