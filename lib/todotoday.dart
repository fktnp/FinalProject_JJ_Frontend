import 'package:flutter/material.dart';
import 'calendar.dart';
import 'task.dart';

class TryTodotoday extends StatefulWidget {
  const TryTodotoday({super.key});

  @override
  TryTodotodayState createState() => TryTodotodayState();
}

class TryTodotodayState extends State<TryTodotoday> {
  DateTime currentDateTime = DateTime.now();

  void _onDateChanged(DateTime date) {
    setState(() {
      currentDateTime = date;
    });
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
              const TaskForADay(),
              CurrentDayDateRow(
                title: "try",
                onDateChanged: _onDateChanged, // ส่ง callback ไป
              ),
              TaskTable(currentDate: currentDateTime), // ส่ง currentDate ไปที่ TaskTable
            ],
          ),
        ),
      ),
    );
  }
}

class TaskForADay extends StatelessWidget {
  const TaskForADay({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.01),
      padding: EdgeInsets.fromLTRB(screenWidth * 0.08, screenHeight * 0.01, screenWidth * 0.08, screenHeight * 0.01),
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

class TaskTable extends StatelessWidget {
  final DateTime currentDate;

  const TaskTable({super.key, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Expanded(
      child: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
          color: Color(0xFFFFECDB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: FutureBuilder<List<Task>>(
          future: loadTasks(), // Loading tasks from JSON
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tasks found'));
            } else {
              final tasks = snapshot.data!.where((task) =>
                  task.taskDate.year == currentDate.year &&
                  task.taskDate.month == currentDate.month &&
                  task.taskDate.day == currentDate.day);

              final aloneTasks = tasks.where((task) => task.taskType == 'alone').toList();
              final coOpTasks = tasks.where((task) => task.taskType == 'Co-Op').toList();

              return Padding(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.03, screenWidth * 0.05, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...aloneTasks.map((task) => TodayTask(task: task)),
                      Text(
                        "Co-Op",
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          color: const Color.fromARGB(255, 26, 26, 26),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      ...coOpTasks.map((task) => TodayTask(task: task)),
                    ],
                  ),
                )
              );
            }
          },
        ),
      ),
    );
  }
}