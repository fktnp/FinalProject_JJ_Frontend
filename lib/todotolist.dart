import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/calendarModel.dart';
import 'package:flutter_application_1/model/subJobModel.dart';
import 'sub_components_calendar/DayDateRow.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  DateTime currentDateTime = DateTime.now();
  List<Task> tasks = [];
  final Dio _dio = Dio();

  Future<List<CalendarModel>> fetchCalendars() async {
    final Dio dio = Dio();
    final response = await dio.get(
        'http://10.0.2.2:8080/v1/calendar/user/59ae0cbd-c715-4f1a-92cc-f9f192dc2837'); // เปลี่ยน URL ตามที่คุณใช้
    // print(response.statusCode);
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

  Future<void> _uncompleteTask(String taskId) async {
    try {
      final response = await _dio.get(
          'http://10.0.2.2:8080/v1/calendar/task/$taskId'); // เปลี่ยน URL ตามที่คุณใช้

      if (response.statusCode == 200) {
        // อัพเดทสถานะของ Task ในตัวแปร tasks
        setState(() {
          final taskIndex = tasks.indexWhere((task) => task.id == taskId);
          if (taskIndex != -1) {
            tasks[taskIndex].isCompleted =
                false; // เปลี่ยนสถานะให้เป็น not completed
          }
        });
      } else {
        throw Exception('Failed to uncomplete task');
      }
    } catch (e) {
      print('Error uncompleting task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      color: const Color(0xFFFFECDB),
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.05),
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.95,
          alignment: AlignmentDirectional.topCenter,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDCBC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Text(currentDateTime.day.toString()),
              const HeadToDo(),
              CurrentDayDateRow(
                title: "try",
                onDateChanged: _onDateChanged, // ส่ง callback ไป
                tragetDateShow: currentDateTime,
              ),
              ShowListTask(
                currentDate: currentDateTime,
                tasks: tasks, // ส่ง tasks ไปที่ ShowListTask
                onTaskCompleted:
                    _completeTask, // ส่ง callback สำหรับ task ที่เสร็จแล้ว
                onTaskUncompleted:
                    _uncompleteTask, // ส่ง callback สำหรับ task ที่ไม่สำเร็จ
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeadToDo extends StatelessWidget {
  const HeadToDo({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.01),
      padding: EdgeInsets.fromLTRB(screenWidth * 0.08, screenHeight * 0.01,
          screenWidth * 0.08, screenHeight * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECDB),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        "Task For A Day",
        style: TextStyle(
          fontSize: screenHeight * 0.03,
          color: const Color.fromARGB(255, 26, 26, 26),
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
  final Function(String)
      onTaskUncompleted; // ฟังก์ชันสำหรับทำให้ Task ไม่สำเร็จ

  const ShowListTask({
    super.key,
    required this.currentDate,
    required this.tasks,
    required this.onTaskCompleted,
    required this.onTaskUncompleted, // เพิ่มฟังก์ชันสำหรับทำให้ Task ไม่สำเร็จ
  });

  // ใน ShowListTask widget
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Expanded(
        child: Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFFFECDB),
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
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    //อันนี้ปัดติ๊กถูก
                    onTaskCompleted(task.id); // เรียกการทำงานเมื่อมีการติ๊กถูก
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        //ไว้ทำการแจ้งเตือนการปัด
                        content: Text('${task.title} marked as completed'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    //อันนี้ปัดยกเลิก
                    onTaskUncompleted(
                        task.id); // เรียกการทำงานเมื่อมีการยกเลิกติ๊กถูก
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        //ไว้ทำการแจ้งเตือนการปัด
                        content: Text('${task.title} marked as uncompleted'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return false;
                  }
                  return false;
                },
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.undo, color: Colors.white),
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
                          'Start: ${task.startDate.toLocal().toString().split(' ')[0]}',
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
                          'End: ${task.lastDate.toLocal().toString().split(' ')[0]}',
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

  Task({
    required this.id,
    required this.title,
    required this.details,
    required this.isCompleted,
    required this.startDate,
    required this.lastDate,
    required this.percentProgress,
  });
}
