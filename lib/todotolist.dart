import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/calendarModel.dart';
import 'package:flutter_application_1/model/subJobModel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'model/teamsubjobmodel.dart';
import 'model/theme.dart';
import 'sub_components_calendar/daydaterow.dart';
import 'package:timezone/timezone.dart' as tz;

class ToDoList extends StatefulWidget {
  final String userId;
  const ToDoList({super.key, required this.userId});

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  DateTime currentDateTime = DateTime.now();
  List<Task> allTasks = [];
  final Dio _dio = Dio();
  bool isNotificationsEnabled = false;

  Future<void> _checkNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? permissionGranted =
        await androidImplementation?.requestPermission();
    setState(() {
      isNotificationsEnabled = permissionGranted ?? false;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print('Notification clicked with payload: ${details.payload}');
      },
    );

    // สร้าง notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'Notifications for upcoming tasks',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ฟังก์ชันสำหรับตั้งเวลาแจ้งเตือนสำหรับ task
  Future<void> _scheduleTaskNotification(Task task) async {
    try {
      // ใช้ startTimeGoal โดยตรงเนื่องจากเป็น DateTime อยู่แล้ว
      final DateTime startTime = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day,
        task.startTimeGoal.hour, // ใช้ .hour แทน split
        task.startTimeGoal.minute, // ใช้ .minute แทน split
      );

      // คำนวณเวลาแจ้งเตือน (30 นาทีก่อน startTime)
      final notificationTime = startTime.subtract(const Duration(minutes: 30));

      // ถ้าเวลาแจ้งเตือนยังไม่ผ่านไป
      if (notificationTime.isAfter(DateTime.now())) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for upcoming tasks',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          task.id.hashCode, // ใช้ hash ของ task id เป็น notification id
          'เตือนความจำ: ${task.title}',
          'งานของคุณจะเริ่มในอีก 30 นาที',
          tz.TZDateTime.from(notificationTime, tz.local),
          platformChannelSpecifics,
          // androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print(
            'Scheduled notification for task: ${task.title} at $notificationTime');
      }
    } catch (e) {
      print('Error scheduling notification for task: $e');
    }
  }

  Future<List<CalendarModel>> fetchCalendars() async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/calendar/user/${widget.userId}';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      print('fetchCalendars complete');
      return data.map((item) => CalendarModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  Future<List<Teamsubjobmodel>> fetchTeamSubTasks() async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/teamSubJob/subjob/${widget.userId}';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      print('fetchTeamSubTasks complete');
      return data.map((item) => Teamsubjobmodel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load team tasks');
    }
  }

  Future<SubJobModel> fetchSubJob(String subJobID) async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final response = await _dio.get('$apiUrl/v1/subjob/$subJobID');
    if (response.statusCode == 200) {
      print('fetchSubJob complete');
      return SubJobModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load subjob');
    }
  }

  void toggleTaskComplete(String taskId, bool isTeamTask) async {
    await _completeTask(taskId, isTeamTask); // API สำหรับเปลี่ยนสถานะ
    setState(() {
      _fetchAllTasks(); // โหลด Task ใหม่จาก Server
    });
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _fetchAllTasks() async {
    try {
      List<Task> fetchedTasks = [];

      // ดึงข้อมูล calendars
      try {
        final List<CalendarModel> calendars = await fetchCalendars();
        // แปลง calendars เป็น Task
        for (var calendar in calendars) {
          try {
            SubJobModel subJob = await fetchSubJob(calendar.subJobID);
            fetchedTasks.add(Task(
              id: calendar.id,
              title: subJob.name,
              details: subJob.details,
              isCompleted: calendar.statusSubJob,
              startDate: subJob.startDate,
              lastDate: subJob.lastDate,
              percentProgress: subJob.percentProgress,
              dateCalendar: calendar.dateCalendar,
              statusSubJob: calendar.statusSubJob,
              startTimeGoal: subJob.startTimeGoal,
              lastTimeGoal: subJob.lastTimeGoal,
              isTeamTask: false,
              status: '',
            ));
          } catch (e) {
            print('Error fetching subjob: $e');
            // ข้าม task นี้ถ้าไม่สามารถดึงข้อมูล subjob ได้
            continue;
          }
        }
      } catch (e) {
        print('Error fetching calendars: $e');
        // ถ้าดึง calendars ไม่ได้ จะมี fetchedTasks เป็น list ว่าง
      }

      // ดึงข้อมูล teamTasks แยกต่างหาก
      try {
        final List<Teamsubjobmodel> teamTasks = await fetchTeamSubTasks();
        // แปลง teamTasks เป็น Task
        for (var teamTask in teamTasks) {
          fetchedTasks.add(Task(
            id: teamTask.subJobId,
            title: "${teamTask.name} (Team)",
            details: teamTask.details,
            isCompleted: teamTask.status == "Complete",
            startDate: teamTask.startDate,
            lastDate: teamTask.lastDate,
            percentProgress: 0,
            dateCalendar: teamTask.startDate,
            statusSubJob: teamTask.status == "Complete",
            startTimeGoal: teamTask.startTime,
            lastTimeGoal: teamTask.lastTime,
            isTeamTask: true,
            status: teamTask.status,
          ));
        }
      } catch (e) {
        print('Error fetching team tasks: $e');
        // ถ้าดึง teamTasks ไม่ได้ จะยังคงมี fetchedTasks จาก calendars
      }

      // อัพเดท state ไม่ว่าจะดึงข้อมูลส่วนไหนสำเร็จหรือไม่
      setState(() {
        allTasks = fetchedTasks;
        print('all task complete with ${fetchedTasks.length} tasks');
        _scheduleNotificationsForToday();
      });
    } catch (e) {
      print('Error in _fetchAllTasks: $e');
    }
  }

  void _scheduleNotificationsForToday() {
    final now = DateTime.now();
    for (var task in allTasks) {
      // เช็คว่าเป็น task ของวันนี้
      if (isSameDate(task.startDate, now) && !task.isCompleted) {
        _scheduleTaskNotification(task);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkNotificationPermission();
    _fetchAllTasks();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      currentDateTime = date;
    });
  }

  Future<void> _completeTask(String taskId, bool isTeamTask,
      {bool complete = true}) async {
    try {
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;

      if (isTeamTask) {
        // สำหรับ team task ส่ง status เป็น "Complete" หรือ status เดิม
        final task = allTasks.firstWhere((t) => t.id == taskId);
        // final String newStatus = complete ? "Complete" : task.status;
        final String newStatus;

        final String endpoint = '$apiUrl/v1/teamSubJob/$taskId';
        if (task.status == 'Complete') {
          newStatus = 'Incomplete';
        } else {
          newStatus = 'Complete';
        }
        final response = await _dio.put(
          endpoint,
          data: {'status': newStatus},
        );

        if (response.statusCode == 200) {
          setState(() {
            final taskIndex = allTasks.indexWhere((t) => t.id == taskId);
            if (taskIndex != -1) {
              allTasks[taskIndex].isCompleted = complete;
              allTasks[taskIndex].statusSubJob = complete;
              allTasks[taskIndex].status = newStatus;
            }
            print('team finish');
          });
        }
      } else {
        // สำหรับ calendar task (ใช้โค้ดเดิม)
        final String endpoint = '$apiUrl/v1/calendar/task/$taskId';
        print('endpoint = $endpoint');
        final response = await _dio.get(endpoint);

        if (response.statusCode == 200) {
          setState(() {
            final taskIndex = allTasks.indexWhere((t) => t.id == taskId);
            if (taskIndex != -1) {
              allTasks[taskIndex].isCompleted = true;
              allTasks[taskIndex].statusSubJob = true;
            }
          });
        }
      }
    } catch (e) {
      print('Error completing task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    final filteredTasks = filterTasks(allTasks);

    return Container(
      color: pastel.pastel2,
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.05),
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.95,
          alignment: AlignmentDirectional.topCenter,
          decoration: BoxDecoration(
            color: pastel.pastel1,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const HeadToDo(),
              CurrentDayDateRow(
                title: "try",
                onDateChanged: _onDateChanged,
                tragetDateShow: currentDateTime,
              ),
              ShowListTask(
                currentDate: currentDateTime,
                tasks: filteredTasks,
                onTaskCompleted: (String taskId) {
                  final task = allTasks.firstWhere((t) => t.id == taskId);
                  toggleTaskComplete(taskId, task.isTeamTask);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Task> filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      if (task.isTeamTask) {
        // แสดง task team ทุกวันในช่วง startDate ถึง lastDate
        return currentDateTime
                .isAfter(task.startDate.subtract(const Duration(days: 1))) &&
            currentDateTime
                .isBefore(task.lastDate.add(const Duration(days: 1)));
      } else {
        // สำหรับ task ปกติ แสดงเฉพาะวันที่ตรงกับ dateCalendar
        return isSameDate(task.dateCalendar, currentDateTime);
      }
    }).toList();
  }
}

class HeadToDo extends StatelessWidget {
  const HeadToDo({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.01),
      padding: EdgeInsets.fromLTRB(screenWidth * 0.08, screenHeight * 0.01,
          screenWidth * 0.08, screenHeight * 0.01),
      decoration: BoxDecoration(
        color: pastel.pastel2,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        overflow: TextOverflow.ellipsis,
        AppLocalizations.of(context).translate('task_for_a_day'),
        style: TextStyle(
          fontSize: screenHeight * 0.03,
          color: pastel.pastelFont,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class ShowListTask extends StatelessWidget {
  final DateTime currentDate;
  final List<Task> tasks;
  final Function(String) onTaskCompleted;

  const ShowListTask({
    super.key,
    required this.currentDate,
    required this.tasks,
    required this.onTaskCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    return Expanded(
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: pastel.pastel2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06),
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: pastel.pastel1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Dismissible(
                  key: Key(task.id),
                  direction: task.statusSubJob
                      ? DismissDirection.endToStart // ปัดซ้ายเพื่อยกเลิก
                      : DismissDirection.startToEnd, // ปัดขวาเพื่อ complete
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd &&
                        !task.statusSubJob) {
                      // เมื่อปัดจากซ้ายไปขวา และ StatusSubJob เป็น false (ทำให้ complete)
                      await onTaskCompleted(task.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              overflow: TextOverflow.ellipsis,
                              '${task.title} marked as completed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return false; // รีเฟรชหน้าโดยไม่ลบ task ออกจากหน้าจอ
                    } else if (direction == DismissDirection.endToStart &&
                        task.statusSubJob) {
                      // เมื่อปัดจากขวาไปซ้าย และ StatusSubJob เป็น true (ยกเลิก complete)
                      await onTaskCompleted(task.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              overflow: TextOverflow.ellipsis,
                              '${task.title} marked as not completed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return false; // รีเฟรชหน้าโดยไม่ลบ task ออกจากหน้าจอ
                    }
                    return false;
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      color: task.statusSubJob
                          ? Colors.red
                          : pastel.pastelProgress,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: task.statusSubJob
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      task.statusSubJob ? Icons.cancel : Icons.check,
                      color: pastel.pastel1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      task.title,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.isCompleted
                                            ? pastel.pastelFont2
                                            : pastel.pastelFont,
                                      ),
                                    ),
                                  ),
                                  if (task.isCompleted)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: pastel.pastelFont2,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.hourglass_empty,
                              color: task.isCompleted
                                  ? pastel.pastelFont2
                                  : pastel.pastelFont,
                              size: 20,
                            ),
                          ],
                        ),
                        if (task.details.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              task.details,
                              style: TextStyle(
                                color: task.isCompleted
                                    ? pastel.pastelFont2
                                    : pastel.pastelFont,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            '${AppLocalizations.of(context).translate('stt')}: ${task.startTimeGoal.hour.toString().padLeft(2, '0')} : ${task.startTimeGoal.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: task.isCompleted
                                  ? pastel.pastelFont2
                                  : pastel.pastelFont,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            '${AppLocalizations.of(context).translate('nd')}: ${task.lastTimeGoal.hour.toString().padLeft(2, '0')} : ${task.lastTimeGoal.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: task.isCompleted
                                  ? pastel.pastelFont2
                                  : pastel.pastelFont,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Task {
  final String id; // Changed to String to match subJobId
  final String title; // Maps to name
  final String details; // Added to hold the details
  bool isCompleted; // Maps to status
  final DateTime startDate; // Added to hold the start date
  final DateTime lastDate; // Added to hold the last date
  final int percentProgress; // Added for progress
  late final bool statusSubJob; // Added for progress
  final DateTime dateCalendar;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final bool isTeamTask;
  late final String status;

  Task({
    required this.id,
    required this.title,
    required this.details,
    required this.isCompleted,
    required this.startDate,
    required this.lastDate,
    required this.percentProgress,
    required this.statusSubJob,
    required this.dateCalendar,
    required this.startTimeGoal,
    required this.lastTimeGoal,
    required this.isTeamTask,
    required this.status,
  });
}
