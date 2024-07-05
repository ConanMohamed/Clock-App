import 'package:alarm_app/local_database.dart';

class AlarmModel {
  int? id;
  String title;
  DateTime time;
  bool isActive;

  AlarmModel({
    this.id,
    required this.title,
    required this.time,
    required this.isActive,
  });

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = {
      columnTitle: title,
      columnDateTime: time.toIso8601String(),
      columnActive: isActive ? 1 : 0,
    };
    if (withId && id != null) {
      map[columnId] = id!;
    }
    return map;
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map[columnId],
      title: map[columnTitle],
      time: DateTime.parse(map[columnDateTime]),
      isActive: map[columnActive] == 1,
    );
  }
}
