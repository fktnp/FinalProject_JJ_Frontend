import 'package:flutter/material.dart';
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

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<SubJobModel>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchSubTasks(); // ดึงข้อมูลจาก API เมื่อหน้าเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: FutureBuilder<List<SubJobModel>>(
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
