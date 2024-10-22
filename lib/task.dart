import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<MainTask>> fetchMainTasks() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8080/v1/job'));

  if (response.statusCode == 200) {
    final List<dynamic> taskListJson = jsonDecode(response.body);
    return taskListJson.map((json) => MainTask.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load tasks');
  }
}

class MainTask {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String category;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final int percentProgress;

  MainTask({
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

  factory MainTask.fromJson(Map<String, dynamic> json) {
    return MainTask(
      jobId: json['JobID'],
      userId: json['UserID'],
      name: json['Name'],
      status: json['Status'],
      category: json['Category'],
      details: json['Details'],
      startTimeGoal: DateTime.parse(json['StartTimeGoal']),
      lastTimeGoal: DateTime.parse(json['LastTimeGoal']),
      percentProgress: json['PercentProgress'],
    );
  }
}

//Subjob
Future<List<SubJob>> fetchSubTasks() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8080/v1/subjob'));

  if (response.statusCode == 200) {
    final List<dynamic> taskListJson = jsonDecode(response.body);
    return taskListJson.map((json) => SubJob.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load tasks');
  }
}

class SubJob {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final DateTime startDate;
  final DateTime lastDate;
  final String frequency;
  final int frequencyDay;
  final String frequencyWeek;
  final int frequencyMonth;
  final String headSubJobId;

  SubJob({
    required this.jobId,
    required this.userId,
    required this.name,
    required this.status,
    required this.details,
    required this.startTimeGoal,
    required this.lastTimeGoal,
    required this.startDate,
    required this.lastDate,
    required this.frequency,
    required this.frequencyDay,
    required this.frequencyWeek,
    required this.frequencyMonth,
    required this.headSubJobId,
  });

  factory SubJob.fromJson(Map<String, dynamic> json) {
    return SubJob(
      jobId: json['job_id'],
      userId: json['user_id'],
      name: json['name'],
      status: json['status'],
      details: json['details'],
      startTimeGoal: DateTime.parse(json['start_time_goal']),
      lastTimeGoal: DateTime.parse(json['last_time_goal']),
      startDate: DateTime.parse(json['start_date']),
      lastDate: DateTime.parse(json['last_date']),
      frequency: json['frequency'],
      frequencyDay: json['frequency_day'],
      frequencyWeek: json['frequency_week'],
      frequencyMonth: json['frequency_Month'],
      headSubJobId: json['head_sub_job_id'],
    );
  }
}


class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<MainTask>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchMainTasks(); // ดึงข้อมูลจาก API เมื่อหน้าเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: FutureBuilder<List<MainTask>>(
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
                    title: Text(task.name),
                    subtitle: Text(
                        'Start: ${task.startTimeGoal} \nEnd: ${task.lastTimeGoal}'),
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