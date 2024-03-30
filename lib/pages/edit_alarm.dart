import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm_and_weather_app/provider/provider.dart';

class EditAlarm extends StatefulWidget {
  final int alarmIndex;

  const EditAlarm({Key? key, required this.alarmIndex}) : super(key: key);

  @override
  _EditAlarmState createState() => _EditAlarmState();
}

class _EditAlarmState extends State<EditAlarm> {
  late TextEditingController _labelController;
  bool _repeat = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    final alarmProvider = context.read<AlarmProvider>();
    final alarm = alarmProvider.modelist[widget.alarmIndex];
    _labelController.text = alarm.label!;
    _repeat = alarm.when == 'Everyday'; // Assuming 'Everyday' means repeat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Repeat daily'),
                Checkbox(
                  value: _repeat,
                  onChanged: (value) {
                    setState(() {
                      _repeat = value!;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final alarmProvider = context.read<AlarmProvider>();
                final alarm = alarmProvider.modelist[widget.alarmIndex];
                alarmProvider.editAlarm(
                  widget.alarmIndex,
                  _labelController.text,
                  _repeat ? 'Everyday' : 'none',
                );
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}