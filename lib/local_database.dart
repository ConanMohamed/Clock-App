import 'package:sqflite/sqflite.dart';
import 'package:alarm_app/Models/alarm_model.dart';

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnDateTime = 'time';
const String columnActive = 'isActive';

class AlarmHelper {
  static Database? _database;
  static AlarmHelper? _alarmHelper;

  AlarmHelper._createInstance();
  factory AlarmHelper() {
    _alarmHelper ??= AlarmHelper._createInstance();
    return _alarmHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = "$dir/alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $tableAlarm ( 
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
            $columnTitle TEXT NOT NULL,
            $columnDateTime TEXT NOT NULL,
            $columnActive INTEGER NOT NULL
          )
        ''');
      },
    );
    return database;
  }

  Future<void> insertAlarm(AlarmModel alarmInfo) async {
    var db = await database;
    await db.insert(tableAlarm, alarmInfo.toMap(withId: false));
  }

  Future<List<AlarmModel>> getAlarms() async {
    List<AlarmModel> alarms = [];

    var db = await database;
    var result = await db.query(tableAlarm);
    for (var element in result) {
      var alarmInfo = AlarmModel.fromMap(element);
      alarms.add(alarmInfo);
    }

    return alarms;
  }

  Future<int> delete(int? id) async {
    var db = await database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }
}
