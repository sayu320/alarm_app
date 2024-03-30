import 'dart:math';

import 'package:alarm_and_weather_app/provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});

  @override
  State<AddAlarm> createState() => _AddAlaramState();
}

class _AddAlaramState extends State<AddAlarm> {
  late TextEditingController controller;

  String? dateTime;
  bool repeat = false;

  DateTime? notificationtime;

  String? name = "none";
  int? milliseconds;

  @override
  void initState() {
    controller = TextEditingController();
    context.read<AlarmProvider>().getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: true,
        title: const Text(
          'Add Alarm',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date and time picker
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: CupertinoDatePicker(
              showDayOfWeek: true,
              minimumDate: DateTime.now(),
              dateOrder: DatePickerDateOrder.dmy,
              onDateTimeChanged: (va) {
                dateTime = DateFormat().add_jms().format(va);

                milliseconds = va.microsecondsSinceEpoch;

                notificationtime = va;

                print(dateTime);
              },
            )),
          ),
           // Label input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border:
                        Border.all(color: Colors.deepPurpleAccent, width: 2)),
                width: MediaQuery.of(context).size.width,
                child: CupertinoTextField(
                  placeholder: "Add Label",
                  controller: controller,
                )),
          ),
          // Repeat switch
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  " Repeat daily",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
              CupertinoSwitch(
                value: repeat,
                onChanged: (bool value) {
                  repeat = value;

                  if (repeat == false) {
                    name = "none";
                  } else {
                    name = "Everyday";
                  }

                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          
          // Set Alarm button
          ElevatedButton(
              onPressed: () {
                // Generate a random number for alarm ID
                Random random = Random();
                int randomNumber = random.nextInt(100);
               // Set alarm details and save to provider
                context.read<AlarmProvider>().setAlaram(controller.text,
                    dateTime!, true, name!, randomNumber, milliseconds!);
                    // Save updated alarm data to provider
                context.read<AlarmProvider>().setData();
                     // Schedule notification for the alarm
                context
                    .read<AlarmProvider>()
                    .scheduleNotification(notificationtime!, randomNumber);
                // Navigate back to previous screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              child: const Text(
                "Set Alarm",
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
        ],
      ),
    );
  }
}
