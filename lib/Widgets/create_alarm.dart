import 'dart:io';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:alarm_app/local_database.dart';
import 'package:alarm_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class NewAlarm extends StatefulWidget {
  const NewAlarm({super.key, required this.createAlarm});
  final void Function(AlarmModel alarm) createAlarm;

  @override
  State<NewAlarm> createState() => _NewAlarmState();
}

  List<AlarmModel>? currentAlarms;
class _NewAlarmState extends State<NewAlarm> {
  DateTime? alarmTime;
  final AlarmHelper alarmHelper = AlarmHelper();
  Future<List<AlarmModel>>? _alarms;
  final TextEditingController _titleController = TextEditingController();
  String _alarmTimeString = DateFormat('HH:mm').format(DateTime.now());
  String _selectedSound = 'lib/Assets/ringtone-1.mp3';

  Map<String, String> sounds = {
    'ringtone 1': 'lib/Assets/ringtone-1.mp3',
    'ringtone 2': 'lib/Assets/ringtone-2.mp3'
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    alarmTime = DateTime.now();
    alarmHelper.initializeDatabase().then((_) {
      loadAlarms();
    });
  }

  void loadAlarms() {
    _alarms = alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  void showDialogs() {
    Platform.isIOS
        ? showCupertinoDialog(
            context: context,
            builder: (contx) => CupertinoAlertDialog(
                  title: const Text('Invalid input!'),
                  content: const Text(
                      'Please make sure valid title, Alarm Time and Sound.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contx),
                      child: const Text('Okay'),
                    ),
                  ],
                ))
        : showDialog(
            context: context,
            builder: (contx) => AlertDialog(
                  title: const Text('Invalid input!'),
                  content: const Text(
                      'Please make sure valid title, Alarm Time and Sound.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(contx),
                      child: const Text('Okay'),
                    ),
                  ],
                ));
  }

  void onSaveAlarm(bool isRepeating) {
    DateTime? scheduleAlarmDateTime;
    if (alarmTime!.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = alarmTime;
    } else {
      scheduleAlarmDateTime = alarmTime!.add(const Duration(days: 1));
    }

    var alarmInfo = AlarmModel(
      id: 0,
      title: _titleController.text,
      time: scheduleAlarmDateTime!,
      isActive: true,
    );

    alarmHelper.insertAlarm(alarmInfo);
    widget.createAlarm(alarmInfo);
    scheduleAlarm(alarmInfo.time, _alarmTimeString, isRepeating: isRepeating);
    loadAlarms();
  }

  void scheduleAlarm(DateTime scheduledNotificationDateTime, String alarmTitle,
      {bool isRepeating = false}) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'alarm_bill',
      sound: RawResourceAndroidNotificationSound('ringtone_1'),
      largeIcon: DrawableResourceAndroidBitmap('alarm_bill'),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    var scheduledTime =
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local);

    if (isRepeating) {
      // Example of repeating alarm (not exact)
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Office',
        alarmTitle,
        scheduledTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Adjust based on your needs
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'Alarm Payload',
      );
    } else {
      // Single non-repeating exact alarm
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Office',
        alarmTitle,
        scheduledTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Title'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: DropdownButton(
                          value: _selectedSound,
                          items: sounds.keys
                              .map(
                                (e) => DropdownMenuItem(
                                    value: sounds[e], child: Text(e)),
                              )
                              .toList(),
                          onChanged: (object) {
                            if (object == null) {
                              return;
                            }
                            setState(() {
                              _selectedSound = object;
                            });
                          })),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final now = DateTime.now();
                              var selectedDateTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  pickedTime.hour,
                                  pickedTime.minute);
                              alarmTime = selectedDateTime;
                              setState(() {
                                alarmTime = selectedDateTime;
                                _alarmTimeString = DateFormat('HH:mm')
                                    .format(selectedDateTime);
                              });
                            }
                          },
                          icon: const Icon(Icons.timer),
                          label: Text(_alarmTimeString),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty ||
                          alarmTime == null) {
                        showDialogs();
                      } else {
                        onSaveAlarm(true);
                        Navigator.pop(context);
                        loadAlarms();
                        ()async{
                          currentAlarms = await _alarms;
                        };
                        setState(() {
                          currentAlarms;
                        });
                      }
                    },
                    icon: const Icon(Icons.alarm),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
