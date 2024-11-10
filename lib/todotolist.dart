import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/calendarModel.dart';
import 'package:flutter_application_1/model/subJobModel.dart';
import 'model/theme.dart';
import 'sub_components_calendar/daydaterow.dart';

class ToDoList extends StatefulWidget {
  final String userId;
  const ToDoList({super.key, required this.userId});

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  DateTime currentDateTime = DateTime.now();
  List<Task> tasks = [];
  final Dio _dio = Dio();

  Future<List<CalendarModel>> fetchCalendars() async {
    final Dio dio = Dio();
    final String url =
        'http://10.0.2.2:8080/v1/calendar/user/${widget.userId}'; // เปลี่ยน URL ตามที่คุณใช้
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => CalendarModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  Future<SubJobModel> fetchSubJob(String subJobID) async {
    final Dio dio = Dio();
    final response = await dio.get(
        'http://10.0.2.2:8080/v1/subjob/$subJobID'); // เปลี่ยน URL ตามที่คุณใช้

    if (response.statusCode == 200) {
      return SubJobModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load subjob');
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _fetchTasks() async {
    try {
      List<CalendarModel> calendars = await fetchCalendars();
      List<Task> fetchedTasks = []; // To hold the fetched tasks

      // ดึง subJobId จาก calendars
      for (var calendar in calendars) {
        SubJobModel subJob = await fetchSubJob(calendar.subJobID);
        // Create a Task from the SubJobModel
        fetchedTasks.add(Task(
          id: calendar.id,
          title: subJob.name,
          details: subJob.details,
          isCompleted: calendar.statusSubJob,
          startDate: subJob.startDate,
          lastDate: subJob.lastDate,
          percentProgress: subJob.percentProgress,
          dateCarendar: calendar.dateCalendar,
          startTimeGoal: subJob.startTimeGoal,
          lastTimeGoal: subJob.lastTimeGoal,
        ));
      }
      // Update the tasks state
      setState(() {
        tasks = fetchedTasks;
        print(tasks);
      });
    } catch (e) {
      // Handle any errors that may occur during fetching
      print('Error fetching tasks: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // เรียกใช้งานเมื่อต้องการให้โหลด tasks
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      currentDateTime = date;
    });
  }

  Future<List<CalendarModel>> fetchCalendarsToday() async {
    final Dio dio = Dio();
    final response = await dio.get(
      'http://10.0.2.2:8080/v1/calendar/today/user/${widget.userId}',
    );

    if (response.statusCode == 200) {
      // Assuming response.data is a list of JSON objects
      return (response.data as List)
          .map((json) => CalendarModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load subjobs');
    }
  }

  Future<void> _completeTask(String taskId) async {
    try {
      final response = await _dio.get(
          'http://10.0.2.2:8080/v1/calendar/task/$taskId'); // เปลี่ยน URL ตามที่คุณใช้

      if (response.statusCode == 200) {
        // อัพเดทสถานะของ Task ในตัวแปร tasks
        setState(() {
          final taskIndex = tasks.indexWhere((task) => task.id == taskId);
          if (taskIndex != -1) {
            tasks[taskIndex].isCompleted =
                true; // เปลี่ยนสถานะให้เป็น completed
          }
        });
      } else {
        throw Exception('Failed to complete task');
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

    // กรอง task ที่ตรงกับ currentDateTime
    final filteredTasks = filterTasks(tasks);

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
                onDateChanged: _onDateChanged, // ส่ง callback ไป
                tragetDateShow: currentDateTime,
              ),
              ShowListTask(
                currentDate: currentDateTime,
                tasks: filteredTasks, // แสดงเฉพาะ task ที่ตรงกับวันที่
                onTaskCompleted: _completeTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

// เพิ่มฟังก์ชัน filterTasks เพื่อกรอง tasks ที่ตรงกับวันที่
  List<Task> filterTasks(List<Task> tasks) {
    return tasks
        .where((task) => isSameDate(task.dateCarendar, currentDateTime))
        .toList();
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
        "Task For A Day",
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
  final Function(String) onTaskCompleted; // ฟังก์ชันสำหรับทำให้ Task สำเร็จ

  const ShowListTask({
    super.key,
    required this.currentDate,
    required this.tasks,
    required this.onTaskCompleted,
  });

  // ใน ShowListTask widget
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // final screenHeight = mediaQuery.size.height;
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Dismissible(
                key: Key(task.id),
                direction: task.isCompleted
                    ? DismissDirection
                        .none // ไม่อนุญาตให้ปัดถ้า task ถูก complete แล้ว
                    : DismissDirection
                        .startToEnd, // อนุญาตให้ปัดได้จากซ้ายไปขวาเท่านั้น
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd &&
                      !task.isCompleted) {
                    // เมื่อปัดจากซ้ายไปขวา และ task ยังไม่ complete
                    await onTaskCompleted(
                        task.id); // เรียกการทำงานเมื่อ task สำเร็จ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${task.title} marked as completed'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return false; // เพื่อให้ dismissible กลับสู่สภาพเดิมหลังแสดงผลสำเร็จ
                  }
                  return false;
                },
                background: Container(
                  decoration: BoxDecoration(
                    color: pastel.pastelProgress,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check, color: Colors.white),
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
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.isCompleted
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (task.isCompleted)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.hourglass_empty,
                            color:
                                task.isCompleted ? Colors.grey : Colors.black54,
                            size: 20,
                          ),
                        ],
                      ),
                      // แสดงรายละเอียดของ Task ถ้ามี
                      if (task.details.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            task.details,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      // คุณสามารถเพิ่มการแสดงวันเริ่มต้นและวันสิ้นสุดถ้าจำเป็น
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Start: ${task.startTimeGoal.hour.toString().padLeft(2, '0')} :'
                          ' ${task.startTimeGoal.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color:
                                task.isCompleted ? Colors.grey : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'End: ${task.lastTimeGoal.hour.toString().padLeft(2, '0')} :'
                          ' ${task.lastTimeGoal.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color:
                                task.isCompleted ? Colors.grey : Colors.black54,
                            fontSize: 14,
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
    ));
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
  final DateTime dateCarendar;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;

  Task({
    required this.id,
    required this.title,
    required this.details,
    required this.isCompleted,
    required this.startDate,
    required this.lastDate,
    required this.percentProgress,
    required this.dateCarendar,
    required this.startTimeGoal,
    required this.lastTimeGoal,
  });
}
