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
              TaskTable(
                  currentDate:
                      currentDateTime), // ส่ง currentDate ไปที่ TaskTable
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
        decoration: BoxDecoration(
          color: const Color(0xFFFFECDB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06),
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: FutureBuilder<List<MainTask>>(
          future: fetchMainTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tasks found'));
            } else {
              final tasks = snapshot.data!.where((task) =>
                  (task.startTimeGoal.isBefore(currentDate) ||
                      task.startTimeGoal.isAtSameMomentAs(currentDate)) &&
                  (task.lastTimeGoal.isAfter(currentDate) ||
                      task.lastTimeGoal.isAtSameMomentAs(currentDate)));

              return Padding(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                    screenHeight * 0.03, screenWidth * 0.05, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Generate task widgets only once per task
                      ...tasks.map((task) => TodayTask(
                            task: task,
                            startDate: task.startTimeGoal,
                            endDate: task.lastTimeGoal,
                          )),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class TodayTask extends StatelessWidget {
  final MainTask task;
  final DateTime startDate;
  final DateTime endDate;

  const TodayTask(
      {super.key,
      required this.task,
      required this.startDate,
      required this.endDate});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.11,
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
      padding:
          EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade100, // Use your color logic here
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: TextStyle(fontSize: screenWidth * 0.065),
          ),
          const SizedBox(height: 5),
          // Show the start and end date in one line
          Text(
            '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ],
      ),
    );
  }
}
