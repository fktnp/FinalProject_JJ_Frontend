import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  TaskListState createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No tasks found');
        } else {
          final tasks = snapshot.data!;
          return Stack(
            children: [
              Container(
                width: 200,
                height: 400,
                color: const Color.fromARGB(255, 26, 73, 7),
              ),
              Positioned(
                top: 10,
                left: 10,
                bottom: 10,
                child: Container(
                  width: 300,
                  height: 160,
                  color: Colors.amber,
                ),
              ),
              // ListView.builder(
              //   itemCount: tasks.length,
              //   itemBuilder: (context, index) {
              //     final task = tasks[index];
              //     return ListTile(
              //       title: Text(task.taskName),
              //       subtitle: Text(
              //           '${task.taskStartHour}:00 - ${task.taskEndHour}:00'),
              //     );
              //   },
              // )
            ],
          );
        }
      },
    );
  }
}

Future<List<Task>> loadTasks() async {
  final jsonString = await rootBundle.loadString('lib/components/trytask.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Task.fromJson(json)).toList();
}

class Task {
  final int taskStartHour;
  final int taskEndHour;
  final DateTime taskDate;
  final String taskName;
  final String taskType;
  final String taskCore;

  Task({
    required this.taskStartHour,
    required this.taskEndHour,
    required this.taskDate,
    required this.taskName,
    required this.taskType,
    required this.taskCore,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskStartHour: json['taskStartHour'],
      taskEndHour: json['taskEndHour'],
      taskDate: DateTime.parse(json['taskDate']),
      taskName: json['taskName'],
      taskType: json['taskType'],
      taskCore: json['taskCore'],
    );
  }

  get description => null;
}

class AddedDayTask extends StatelessWidget {
  final Task task;
  final double boxheight;
  const AddedDayTask({super.key, required this.task, required this.boxheight});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container(
        height: boxheight,
        width: screenWidth * 0.28,
        decoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              task.taskName,
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 26, 26, 26),
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${task.taskStartHour.toString().padLeft(2, '0')}:00 - ${task.taskEndHour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 26, 26, 26),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
  }
}

class TodayTask extends StatelessWidget {
  final Task task;
  const TodayTask({super.key, required this.task});

  Color _getRandomPastelColor() {
    final Random random = Random();
    final int r = (random.nextInt(256) + 255) ~/ 2;
    final int g = (random.nextInt(256) + 255) ~/ 2;
    final int b = (random.nextInt(256) + 255) ~/ 2;
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final Color randomPastelColor = _getRandomPastelColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: screenHeight * 0.09,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: randomPastelColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                screenHeight * 0.005, screenWidth * 0.05, 0),
            child: Text(
              task.taskName,
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                color: const Color.fromARGB(255, 26, 26, 26),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05, 0, screenWidth * 0.05, 0),
            child: Text(
              '${task.taskStartHour.toString().padLeft(2, '0')}:00 - ${task.taskEndHour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: screenHeight * 0.024,
                color: const Color.fromARGB(
                    255, 26, 26, 26), // Ensure text is visible
                decoration: TextDecoration.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TaskManager {
  // Path to the provided JSON file
  final String filePath = 'lib/components/trytask.json';

  Future<File> _getFile() async {
    return File(filePath);
  }

  Future<List<dynamic>> _readTasks() async {
    try {
      final file = await _getFile();
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (e) {
      return []; // If file reading fails, return an empty list
    }
  }

  Future<void> _writeTasks(List<dynamic> tasks) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(tasks));
  }

  Future<void> addTask(String taskName, int startHour, int endHour,
      DateTime taskDate, String goal) async {
    // Load existing tasks
    final tasks = await _readTasks();

    // Create new task
    final newTask = {
      "taskName": taskName,
      "taskStartHour": startHour,
      "taskEndHour": endHour,
      "taskDate": taskDate
          .toIso8601String()
          .split('T')
          .first, // Save only the date part
      "taskType": "alone",
      "taskCore": goal, // Set the goal from passed variable
    };

    // Add the new task to the existing tasks
    tasks.add(newTask);

    // Write back to JSON
    await _writeTasks(tasks);
  }
}

class GoaladdPage extends StatefulWidget {
  const GoaladdPage({super.key});
  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoaladdPage> {
  // Variables for storing user input
  String? goalName;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? frequency;
  DateTime? endDate;
  int? dayInterval; // for daily frequency
  int? weekInterval; // for weekly frequency
  List<String> selectedDaysOfWeek = []; // for days of the week
  int? monthInterval; // for monthly frequency
  int? selectedDayOfMonth; // for monthly date
  String? selectedMonth; // for yearly frequency
  int? yearInterval; // for yearly frequency

  // List of frequencies
  List<String> frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> monthsOfYear = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // Function to pick start time
  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  // Function to pick end time
  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }

  // Function to pick end date using Flutter's showDatePicker
  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Goal Name Input
            TextField(
              decoration: InputDecoration(labelText: 'Goal Name'),
              onChanged: (value) {
                setState(() {
                  goalName = value;
                });
              },
            ),
            SizedBox(height: 16.0),

            // Time Picker for Start Time
            ListTile(
              title: Text(startTime != null
                  ? "Start Time: ${startTime!.format(context)}"
                  : "Pick Start Time"),
              trailing: Icon(Icons.access_time),
              onTap: () => _pickStartTime(context),
            ),

            // Time Picker for End Time
            ListTile(
              title: Text(endTime != null
                  ? "End Time: ${endTime!.format(context)}"
                  : "Pick End Time"),
              trailing: Icon(Icons.access_time),
              onTap: () => _pickEndTime(context),
            ),

            // Frequency Dropdown
            DropdownButton<String>(
              hint: Text('Select Frequency'),
              value: frequency,
              onChanged: (String? newValue) {
                setState(() {
                  frequency = newValue;
                  dayInterval = null;
                  weekInterval = null;
                  selectedDaysOfWeek.clear();
                  monthInterval = null;
                  selectedDayOfMonth = null;
                  selectedMonth = null;
                  yearInterval = null;
                });
              },
              items: frequencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),

            // Frequency Specific Options
            if (frequency == 'Daily')
              Column(
                children: [
                  Text('Repeat every'),
                  DropdownButton<int>(
                    value: dayInterval,
                    hint: Text('Day(s)'),
                    onChanged: (int? value) {
                      setState(() {
                        dayInterval = value;
                      });
                    },
                    items: List.generate(7, (index) => index + 1)
                        .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Day(s)'),
                            ))
                        .toList(),
                  ),
                ],
              ),
            if (frequency == 'Weekly')
              Column(
                children: [
                  Text('Repeat every'),
                  DropdownButton<int>(
                    value: weekInterval,
                    hint: Text('Week(s)'),
                    onChanged: (int? value) {
                      setState(() {
                        weekInterval = value;
                      });
                    },
                    items: List.generate(4, (index) => index + 1)
                        .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Week(s)'),
                            ))
                        .toList(),
                  ),
                  Text('On these days'),
                  Wrap(
                    spacing: 8.0,
                    children: daysOfWeek.map((day) {
                      return FilterChip(
                        label: Text(day),
                        selected: selectedDaysOfWeek.contains(day),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedDaysOfWeek.add(day);
                            } else {
                              selectedDaysOfWeek.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (frequency == 'Monthly')
              Column(
                children: [
                  Text('Repeat every'),
                  DropdownButton<int>(
                    value: monthInterval,
                    hint: Text('Month(s)'),
                    onChanged: (int? value) {
                      setState(() {
                        monthInterval = value;
                      });
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Month(s)'),
                            ))
                        .toList(),
                  ),
                  Text('On day'),
                  DropdownButton<int>(
                    value: selectedDayOfMonth,
                    hint: Text('Day of Month'),
                    onChanged: (int? value) {
                      setState(() {
                        selectedDayOfMonth = value;
                      });
                    },
                    items: List.generate(31, (index) => index + 1)
                        .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('Day $value'),
                            ))
                        .toList(),
                  ),
                ],
              ),
            if (frequency == 'Yearly')
              Column(
                children: [
                  Text('Repeat every'),
                  DropdownButton<int>(
                    value: yearInterval,
                    hint: Text('Year(s)'),
                    onChanged: (int? value) {
                      setState(() {
                        yearInterval = value;
                      });
                    },
                    items: List.generate(10, (index) => index + 1)
                        .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Year(s)'),
                            ))
                        .toList(),
                  ),
                  Text('In month'),
                  DropdownButton<String>(
                    value: selectedMonth,
                    hint: Text('Month'),
                    onChanged: (String? value) {
                      setState(() {
                        selectedMonth = value;
                      });
                    },
                    items: monthsOfYear
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                  ),
                ],
              ),

            // Date Picker for End Date using Flutter's showDatePicker
            ListTile(
              title: Text(endDate != null
                  ? "End Date: ${endDate!.toLocal()}".split(' ')[0]
                  : "Pick End Date"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickEndDate(context),
            ),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Handle the submission logic here
                print('Goal Name: $goalName');
                print('Start Time: ${startTime?.format(context)}');
                print('End Time: ${endTime?.format(context)}');
                print('Frequency: $frequency');
                print('Day Interval: $dayInterval');
                print('Week Interval: $weekInterval');
                print('Selected Days: $selectedDaysOfWeek');
                print('Month Interval: $monthInterval');
                print('Selected Day of Month: $selectedDayOfMonth');
                print('Year Interval: $yearInterval');
                print('Selected Month: $selectedMonth');
                print('End Date: $endDate');
              },
              child: const Icon(
                Icons.add,
                color: Colors.black, 
                size: 30, 
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFECDB), 
                shape: const CircleBorder(), 
                padding: const EdgeInsets.all(20), 
              ),
            )
          ],
        ),
      ),
    );
  }
}
