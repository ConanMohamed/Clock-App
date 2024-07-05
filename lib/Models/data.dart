import 'package:alarm_app/Models/alarm_model.dart';

List<AlarmModel> alarms = [
  AlarmModel(title:'office',time: DateTime.now().add(
    const Duration(hours: 1),
  ), isActive: true, id: 1, ),
  AlarmModel(title:'Gym',time: DateTime.now().add(
    const Duration(hours: 2),
  ), isActive: true, id: 2),
  AlarmModel(title:'Food',time: DateTime.now().add(
    const Duration(hours: 2),
  ), isActive: true, id: 3),
];