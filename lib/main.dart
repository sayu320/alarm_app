import 'dart:async';

import 'package:alarm_and_weather_app/consts/weather_api.dart';
import 'package:alarm_and_weather_app/pages/alarm_page.dart';
import 'package:alarm_and_weather_app/pages/edit_alarm.dart';
import 'package:alarm_and_weather_app/pages/weather_page.dart';
import 'package:alarm_and_weather_app/provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as tz;

import 'package:weather/weather.dart';
//initialize flutter local notification plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize time zones data
  tz.initializeTimeZones();
  // Request notification permissions
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();

  runApp(ChangeNotifierProvider(
    create: (contex) => AlarmProvider(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WeatherFactory _wf = WeatherFactory(openWeatherApiKey);
  Weather? _weather;
  bool value = false;

  @override
  void initState() {
    super.initState();

    // Initialize alarm provider and setup periodic timer
    context.read<AlarmProvider>().initilize(context);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // Fetch weather data
    _wf.currentWeatherByCityName("Thrissur").then((w) {
      setState(() {
        _weather = w;
      });
    });

    // Get data for alarm provider
    context.read<AlarmProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEFF5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'Alarm Clock',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather info container
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WeatherPage(),
                  ));
                },
                child: ListTile(
                  leading: const Icon(Icons.cloud, size: 30),
                  title: Text(
                    "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    "${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C / ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Date and Time container
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display day of the week
                  Text(
                    DateFormat('EEEE').format(DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4), // Spacer between day and date
                  // Display date
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4), // Spacer between date and time
                  // Display time
                  Text(
                    DateFormat.jm().format(DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //list of scheduled alarms
          Expanded(
            child: ListView.builder(
              itemCount: context.read<AlarmProvider>().modelist.length,
              itemBuilder: (context, index) {
                final alarm = context.read<AlarmProvider>();
                final int alarmIndex = index;
                return 
                GestureDetector(
                  onTap: () {
                    // Navigate to edit alarm page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAlarm(
                          alarmIndex: alarmIndex,
                        ),
                      ),
                    );
                
                  },
               child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alarm.modelist[alarmIndex].dateTime!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "|${alarm.modelist[alarmIndex].label}",
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                value: (alarm.modelist[alarmIndex]
                                            .milliseconds! <
                                        DateTime.now().microsecondsSinceEpoch)
                                    ? false
                                    : alarm.modelist[alarmIndex].check,
                                onChanged: (v) {
                                  alarm.editSwitch(alarmIndex, v);

                                  alarm.cancelNotification(
                                      alarm.modelist[alarmIndex].id!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Call delete alarm function
                                  alarm.deleteAlarm(alarmIndex);
                                },
                              ),
                            ],
                          ),
                          Text(alarm.modelist[alarmIndex].when!)
                        ],
                      ),
                    ),
                  ),
                )
                );
              },
            ),
          ),
        ],
      ),
      //button to add alarms
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAlarm()),
              );
            },
            backgroundColor: Colors.deepPurpleAccent,
            child: const Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
