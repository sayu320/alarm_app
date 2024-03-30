import 'dart:convert';

import 'package:alarm_and_weather_app/main.dart';
import 'package:alarm_and_weather_app/model/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;

// provider class resposible for managing alarms
class AlarmProvider extends ChangeNotifier {
  late SharedPreferences preferences;

//list to hold alarm models
  List<Model> modelist = [];
//list of string representation of alarms
  List<String> listofstring = [];
//flutterlocalnotificationsplugin instance for managing local notifications
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  late BuildContext context;
//method to set an alarm
  setAlaram(String label, String dateTime, bool check, String repeat, int id,
      int milliseconds) {
    modelist.add(Model(
        label: label,
        dateTime: dateTime,
        check: check,
        when: repeat,
        id: id,
        milliseconds: milliseconds));
    notifyListeners();
  }
//method to edit the switch of an alarm
  editSwitch(int index, bool check) {
    modelist[index].check = check;
    notifyListeners();
  }
//method to retreive data(alarms) from sharedprefs
  getData() async {
    preferences = await SharedPreferences.getInstance();

    List<String>? cominglist = preferences.getStringList("data");

    if (cominglist == null) {
    } else {
      modelist = cominglist.map((e) => Model.fromJson(json.decode(e))).toList();
      notifyListeners();
    }
  }
//method to save data(alarms) to sharedprefs
  setData() {
    listofstring = modelist.map((e) => json.encode(e.toJson())).toList();
    preferences.setStringList("data", listofstring);

    notifyListeners();
  }
//method to initialize flutterlocalnotificationsplugin
  initilize(con) async {
    context = con;
    var androidInitilize = const AndroidInitializationSettings('flutter_logo');
    var iOSinitilize = const DarwinInitializationSettings();
    var initilizationsSettings =
        InitializationSettings(android: androidInitilize, iOS: iOSinitilize);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!.initialize(initilizationsSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }
//callback method for handling notification response
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute<void>(builder: (context) => const MyApp()));
  }
//method to show a notification
  showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }
//method to schedule for a specific date and time
  scheduleNotification(DateTime datetim, int randomnumber) async {
    int newtime =
        datetim.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    print(datetim.millisecondsSinceEpoch);
    print(DateTime.now().millisecondsSinceEpoch);
    print(newtime);
    await flutterLocalNotificationsPlugin!.zonedSchedule(
        randomnumber,
        'Alarm Clock',
        DateFormat().format(DateTime.now()),
        tz.TZDateTime.now(tz.local).add(Duration(milliseconds: newtime)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description',
                sound: RawResourceAndroidNotificationSound("alarm_sound"),
                autoCancel: false,
                playSound: true,
                priority: Priority.max)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
//method to cancel a schedules notification
  cancelNotification(int notificationid) async {
    await flutterLocalNotificationsPlugin!.cancel(notificationid);
  }
//method to delete an alarm
  void deleteAlarm(int index) {
    modelist.removeAt(index); // Remove the alarm at the specified index
    setData(); // Update SharedPreferences or your data storage mechanism
    notifyListeners(); // Notify listeners to update the UI
  }
  // Method to edit scheduled alarms
  void editScheduledAlarm(
      int index, String label, String dateTime, bool check, String repeat) {
    modelist[index].label = label;
    modelist[index].dateTime = dateTime;
    modelist[index].check = check;
    modelist[index].when = repeat;

    setData(); // Update SharedPreferences or your data storage mechanism
    notifyListeners(); // Notify listeners to update the UI
  }
   void editAlarm(int index, String label, String repeat) {
    modelist[index].label = label;
    modelist[index].when = repeat;
    setData();
    notifyListeners();
  }
}
