import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// 🔹 **FCM Service**
/// Handles Firebase Cloud Messaging configuration and notifications
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  /// Get the FCM token
  String? get fcmToken => _fcmToken;

  /// Store and sync FCM token with backend
  Future<void> _storeFcmToken(String token) async {
    try {
      // Store token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // TODO: Send token to your backend
      debugPrint('FCM Token stored locally: $token');

      // Subscribe to global topic for broadcast messages
      await _firebaseMessaging.subscribeToTopic('global');
      debugPrint('Subscribed to global topic');
    } catch (e) {
      debugPrint('Error storing FCM token: $e');
    }
  }

  /// Initialize FCM service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      debugPrint('Starting FCM Service initialization...');

      // Basic Firebase Messaging initialization
      await _initializeFirebaseMessaging();

      // Request permissions if needed
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set up message handlers
      await _setupMessageHandlers();

      _initialized = true;
      debugPrint('FCM Service initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing FCM Service: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - let the app continue without FCM if it fails
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _storeFcmToken(_fcmToken!);
      }
      debugPrint('FCM Token: $_fcmToken');

      // Token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        await _storeFcmToken(token);
        debugPrint('FCM Token Refreshed: $token');
      });
    } catch (e) {
      debugPrint('Error in _initializeFirebaseMessaging: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          criticalAlert: true,
          announcement: true,
        );
        debugPrint(
            'User granted iOS permission: ${settings.authorizationStatus}');
      }

      // Request permission for Android 13+ (API level 33 and above)
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.notification.status;
          if (status.isDenied) {
            await Permission.notification.request();
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _requestPermissions: $e');
      rethrow;
    }
  }

  Future<void> _setupMessageHandlers() async {
    try {
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        try {
          debugPrint('🔔 Received foreground message:');
          debugPrint('- Message ID: ${message.messageId}');
          debugPrint('- Data: ${message.data}');
          debugPrint('- Notification Title: ${message.notification?.title}');
          debugPrint('- Notification Body: ${message.notification?.body}');
          debugPrint('- Sent Time: ${message.sentTime}');

          // Show local notification
          if (message.notification != null) {
            await _showLocalNotification(message);
            debugPrint('✅ Foreground notification displayed');
          }

          // Handle data message
          if (message.data.isNotEmpty) {
            await _handleDataMessage(message.data);
            debugPrint('✅ Foreground data message handled');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error handling foreground message: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      });

      // Handle when app is opened from terminated state
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 App opened from terminated state:');
        debugPrint('- Message ID: ${initialMessage.messageId}');
        await _handleInitialMessage(initialMessage);
      }

      // Handle when app is opened from background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        try {
          debugPrint('🔔 App opened from background state:');
          debugPrint('- Message ID: ${message.messageId}');
          await _handleMessageOpenedApp(message);
        } catch (e, stackTrace) {
          debugPrint('❌ Error handling background-to-foreground message: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      });

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      debugPrint('✅ All message handlers set up successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _setupMessageHandlers: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _handleDataMessage(Map<String, dynamic> data) async {
    try {
      debugPrint('Handling data message: $data');
      // TODO: Implement data message handling logic
      // Example: Navigate to specific screen, update cache, etc.
    } catch (e) {
      debugPrint('Error handling data message: $e');
    }
  }

  Future<void> _handleInitialMessage(RemoteMessage message) async {
    try {
      debugPrint('Handling initial message: ${message.messageId}');
      if (message.data.isNotEmpty) {
        await _handleDataMessage(message.data);
      }
      // TODO: Implement specific navigation or action for initial message
    } catch (e) {
      debugPrint('Error handling initial message: $e');
    }
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    try {
      debugPrint('Handling message opened app: ${message.messageId}');
      if (message.data.isNotEmpty) {
        await _handleDataMessage(message.data);
      }
      // TODO: Implement specific navigation or action when app is opened from notification
    } catch (e) {
      debugPrint('Error handling message opened app: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;
      final iOS = message.notification?.apple;

      if (notification != null) {
        debugPrint('Showing local notification: ${notification.title}');

        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              // Add additional configuration
              playSound: true,
              enableVibration: true,
              showWhen: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
        debugPrint('Local notification displayed successfully');
      } else {
        debugPrint('No notification data in the message');
      }
    } catch (e, stackTrace) {
      debugPrint('Error showing local notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Successfully subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
      rethrow;
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
      rethrow;
    }
  }

  /// Get FCM diagnostic information
  Future<Map<String, dynamic>> getFcmDiagnostics() async {
    try {
      final token = await _firebaseMessaging.getToken();
      final settings = await _firebaseMessaging.getNotificationSettings();
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('fcm_token');

      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        return {
          'current_token': token,
          'stored_token': storedToken,
          'authorization_status': settings.authorizationStatus.toString(),
          'manufacturer': deviceInfo.manufacturer,
          'model': deviceInfo.model,
          'android_version': deviceInfo.version.release,
          'sdk_version': deviceInfo.version.sdkInt.toString(),
          'notification_channel_status':
              await _checkNotificationChannelStatus(),
        };
      } else if (Platform.isIOS) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        return {
          'current_token': token,
          'stored_token': storedToken,
          'authorization_status': settings.authorizationStatus.toString(),
          'model': deviceInfo.model,
          'system_version': deviceInfo.systemVersion,
          'is_physical_device': deviceInfo.isPhysicalDevice,
        };
      }

      return {
        'current_token': token,
        'stored_token': storedToken,
        'authorization_status': settings.authorizationStatus.toString(),
      };
    } catch (e) {
      debugPrint('Error getting FCM diagnostics: $e');
      return {'error': e.toString()};
    }
  }

  Future<String> _checkNotificationChannelStatus() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation == null) {
          return 'Android implementation not found';
        }

        // Check if the channel exists by trying to create it
        const channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
        );

        try {
          await androidImplementation.createNotificationChannel(channel);
          return 'Channel exists or was created successfully';
        } catch (e) {
          return 'Channel creation failed: $e';
        }
      }
      return 'Not Android platform';
    } catch (e) {
      return 'Error checking channel: $e';
    }
  }
}

/// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint('🔔 Starting background message handler...');

    // Initialize Firebase for background handler
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized in background handler');

    debugPrint('📩 Background message details:');
    debugPrint('- Message ID: ${message.messageId}');
    debugPrint('- Data: ${message.data}');
    debugPrint('- Notification Title: ${message.notification?.title}');
    debugPrint('- Notification Body: ${message.notification?.body}');
    debugPrint('- Sent Time: ${message.sentTime}');

    // Initialize local notifications for background messages if needed
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
    debugPrint('✅ Local notifications initialized in background handler');

    // Show notification
    if (message.notification != null) {
      final notification = message.notification!;
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
      debugPrint('✅ Background notification displayed successfully');
    }

    // Handle data message in background
    if (message.data.isNotEmpty) {
      debugPrint('📦 Processing background data message: ${message.data}');
      // TODO: Implement background data handling
      // Note: Avoid heavy processing in background handler
    }

    debugPrint('✅ Background message handling completed successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error in background message handler: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
