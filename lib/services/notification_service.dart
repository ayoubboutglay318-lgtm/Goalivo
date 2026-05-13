import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await compute((_) => tz.initializeTimeZones(), null);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
    return false;
  }

  // Show an immediate notification (goal alert, etc.)
  Future<void> showGoalAlert({
    required String homeTeam,
    required String awayTeam,
    required int homeGoals,
    required int awayGoals,
    String? scorer,
  }) async {
    if (!_initialized) return;
    final body = scorer != null
        ? '⚽ $scorer! $homeTeam $homeGoals–$awayGoals $awayTeam'
        : '⚽ $homeTeam $homeGoals–$awayGoals $awayTeam';

    await _plugin.show(
      _idFromTeams(homeTeam, awayTeam),
      'GOAL!',
      body,
      _details('goals'),
    );
  }

  // Schedule a match reminder N minutes before kick-off
  Future<void> scheduleMatchReminder({
    required int fixtureId,
    required String homeTeam,
    required String awayTeam,
    required DateTime kickOff,
    int minutesBefore = 15,
  }) async {
    if (!_initialized) return;
    final remind = kickOff.subtract(Duration(minutes: minutesBefore));
    if (remind.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      fixtureId,
      'Match Starting Soon ⚽',
      '$homeTeam vs $awayTeam kicks off in $minutesBefore minutes!',
      tz.TZDateTime.from(remind, tz.local),
      _details('reminders'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int fixtureId) async {
    await _plugin.cancel(fixtureId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _details(String channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel == 'goals' ? 'Goal Alerts' : 'Match Reminders',
        channelDescription: channel == 'goals'
            ? 'Notifications when goals are scored'
            : 'Reminders before matches start',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  int _idFromTeams(String home, String away) =>
      (home + away).hashCode.abs() % 100000;
}
