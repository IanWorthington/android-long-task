import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future showNotificationWithoutSound(String title, String body) async {
    //logger.i("Entering Notification.showNotificationWithoutSound($position)");

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'location-bg', 'fetch location in background',
        playSound: false, importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    //logger.i(
    //    "In Notification.showNotificationWithoutSound(), about to await flutterLocalNotificationsPlugin.show");

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: '',
    );

    //logger.i(
    //    "In Notification.showNotificationWithoutSound(), finished awaiting flutterLocalNotificationsPlugin.show");

    //logger.i("Exiting Notification.showNotificationWithoutSound()");
  }

  LocalNotification() {
    //logger.i("Entering Notification()");

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //logger.i("Exiting Notification()");
  }
}