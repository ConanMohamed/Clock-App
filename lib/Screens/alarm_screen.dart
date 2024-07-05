import 'package:flutter/material.dart';
import 'package:alarm_app/Models/alarm_model.dart';
import 'package:alarm_app/Widgets/create_alarm.dart';
import 'package:alarm_app/local_database.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AlarmHelper alarmHelper = AlarmHelper();
  List<AlarmModel> currentAlarms = [];

  @override
  void initState() {
    super.initState();
    loadAlarms();
    requestExactAlarmPermission();
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      // Permission is granted
    } else {
      // Permission is denied, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exact alarm permission is required to set alarms.'),
        ),
      );
    }
  }

  Future<void> loadAlarms() async {
    final alarms = await alarmHelper.getAlarms();
    setState(() {
      currentAlarms = alarms;
    });
  }

  var notActiveColor = Colors.black;

  Future<void> _deleteAlarm(int id) async {
    await alarmHelper.delete(id);
    loadAlarms(); // Refresh the list after deleting an alarm
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(children: [
        ...currentAlarms.map((e) {
          var alarmMinute =
              e.time.minute == 0 ? '00' : e.time.minute.toString();
          var alarmHour = e.time.hour > 12
              ? e.time.hour - 12
              : e.time.hour == 0
                  ? 12
                  : e.time.hour;
          return InkWell(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Delete Alarm',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16.0),
                      const Text('Are you sure you want to delete this alarm?'),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _deleteAlarm(e.id!);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                    color: e.isActive
                        ? Theme.of(context).colorScheme.primary
                        : const Color.fromRGBO(233, 233, 233, 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(4, 5),
                      ),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(
                                '$alarmHour' ':' '$alarmMinute',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: e.isActive
                                            ? Theme.of(context)
                                                .colorScheme
                                                .background
                                            : notActiveColor),
                              ),
                              Text(
                                e.time.hour >= 12 ? 'PM' : 'AM',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: e.isActive
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : notActiveColor,
                                    ),
                              ),
                              Text(
                                '   ${e.title}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Colors.amberAccent),
                              ),
                            ],
                          ),
                          Text(
                            'Sat,Sun,Wed',
                            style: TextStyle(
                                color: e.isActive
                                    ? Theme.of(context).colorScheme.background
                                    : notActiveColor),
                          ),
                        ],
                      ),
                      Switch(
                          value: e.isActive,
                          onChanged: (switching) {
                            setState(() {
                              e.isActive = switching;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.blue)
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(.4),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(5, 7))
                    ],
                    shape: BoxShape.circle),
                height: 60,
                width: 60,
                child: IconButton(
                  onPressed: () async {
                    final result = await showModalBottomSheet<AlarmModel>(
                        isScrollControlled:
                            MediaQuery.of(context).size.width >= 600
                                ? true
                                : false,
                        useSafeArea: true,
                        context: context,
                        builder: (ctx) => NewAlarm(
                              createAlarm: (AlarmModel alarm) {
                                setState(() {
                                  loadAlarms();
                                });
                              },
                            ));

                    if (result != null) {
                      await alarmHelper.insertAlarm(result);
                      loadAlarms(); // Refresh the list after adding a new alarm
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 36,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
