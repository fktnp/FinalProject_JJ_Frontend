import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../todotolist.dart';
import 'calendarmodel.dart';
import 'subjobmodel.dart';

class MainJobModel {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String category;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final int percentProgress;

  MainJobModel({
    required this.jobId,
    required this.userId,
    required this.name,
    required this.status,
    required this.category,
    required this.details,
    required this.startTimeGoal,
    required this.lastTimeGoal,
    required this.percentProgress,
  });

  factory MainJobModel.fromJson(Map<String, dynamic> json) {
    final startTimeGoalJson = json['StartTimeGoal'];
    final lastTimeGoalJson = json['LastTimeGoal'];

    return MainJobModel(
      jobId: json['JobID'],
      userId: json['UserID'],
      name: json['Name'],
      status: json['Status'],
      category: json['Category'],
      details: json['Details'],
      startTimeGoal: DateTime.parse(
        '${startTimeGoalJson['year']}-${startTimeGoalJson['month'].toString().padLeft(2, '0')}-${startTimeGoalJson['day'].toString().padLeft(2, '0')}',
      ),
      lastTimeGoal: DateTime.parse(
        '${lastTimeGoalJson['year']}-${lastTimeGoalJson['month'].toString().padLeft(2, '0')}-${lastTimeGoalJson['day'].toString().padLeft(2, '0')}',
      ),
      percentProgress: json['PercentProgress'],
    );
  }
}

class TaskListView extends StatefulWidget {
  final String userId;
  const TaskListView({super.key, required this.userId});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late Future<List<Task>> futureTasks;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    futureTasks = _fetchTasks(); // Load tasks on page load
  }

  Future<List<Task>> _fetchTasks() async {
    List<CalendarModel> calendars = await fetchCalendars();
    List<Task> fetchedTasks = [];

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
    return fetchedTasks;
  }

  Future<List<CalendarModel>> fetchCalendars() async {
    final String url = 'http://10.0.2.2:8080/v1/calendar/user/${widget.userId}';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => CalendarModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  Future<SubJobModel> fetchSubJob(String subJobID) async {
    final response = await _dio.get('http://10.0.2.2:8080/v1/subjob/$subJobID');

    if (response.statusCode == 200) {
      return SubJobModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load subjob');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List View'),
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      'Details: ${task.details}\n'
                      'Start: ${task.startDate.toLocal().toString().split(' ')[0]}\n'
                      'End: ${task.lastDate.toLocal().toString().split(' ')[0]}\n'
                      'CalendarDate: ${task.dateCarendar.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: Text('${task.percentProgress}%'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// class Trytodo extends StatefulWidget {
//   final String userId;

//   Trytodo({required this.userId});

//   @override
//   _TrytodoState createState() => _TrytodoState();
// }

// class _TrytodoState extends State<Trytodo> {
//   // ตัวแปรสำหรับเก็บข้อมูลที่ได้จาก API
//   var subJobData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSubJobData(); // เรียกใช้ฟังก์ชันเมื่อแอพเริ่มทำงาน
//   }

//   // ฟังก์ชันสำหรับเรียก API
//   Future<void> _fetchSubJobData() async {
//     final url = 'http://10.0.2.2:8080/v1/calendar/subjob/user/${widget.userId}';
    
//     try {
//       final response = await http.get(Uri.parse(url));
      
//       if (response.statusCode == 200) {
//         // แปลงข้อมูลที่ได้จาก API เป็น JSON และเก็บไว้ในตัวแปร
//         setState(() {
//           subJobData = json.decode(response.body);
//         });
//       } else {
//         // แสดงข้อความเมื่อการเรียก API ไม่สำเร็จ
//         print('Failed to load data: ${response.statusCode}');
//       }
//     } catch (error) {
//       // จัดการกับข้อผิดพลาด
//       print('Error fetching data: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Home Page")),
//       body: subJobData == null
//           ? const Center(child: CircularProgressIndicator()) // แสดง loading ระหว่างรอข้อมูล
//           : ListView.builder(
//               itemCount: subJobData.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(subJobData[index]['name']),
//                   subtitle: Text("Start: ${subJobData[index]['start_time']}"),
//                 );
//               },
//             ),
//     );
//   }
// }