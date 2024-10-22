import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<ServerTask>> fetchTasks() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8080/v1/job'));

  if (response.statusCode == 200) {
    final List<dynamic> taskListJson = jsonDecode(response.body);
    return taskListJson.map((json) => ServerTask.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load tasks');
  }
}

class ServerTask {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String category;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final int percentProgress;

  ServerTask({
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

  factory ServerTask.fromJson(Map<String, dynamic> json) {
    return ServerTask(
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

  // Add the copyWith method here
  ServerTask copyWith({
    String? jobId,
    String? userId,
    String? name,
    String? status,
    String? category,
    String? details,
    DateTime? startTimeGoal,
    DateTime? lastTimeGoal,
    int? percentProgress,
  }) {
    return ServerTask(
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      status: status ?? this.status,
      category: category ?? this.category,
      details: details ?? this.details,
      startTimeGoal: startTimeGoal ?? this.startTimeGoal,
      lastTimeGoal: lastTimeGoal ?? this.lastTimeGoal,
      percentProgress: percentProgress ?? this.percentProgress,
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<ServerTask>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasks(); // ดึงข้อมูลจาก API เมื่อหน้าเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: FutureBuilder<List<ServerTask>>(
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


class GoaladdPage extends StatefulWidget {
  const GoaladdPage({super.key});
  @override
  GoalSettingPageState createState() => GoalSettingPageState();
}

class GoalSettingPageState extends State<GoaladdPage> {
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
        title: const Text('Add Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Goal Name Input
            TextField(
              decoration: const InputDecoration(labelText: 'Goal Name'),
              onChanged: (value) {
                setState(() {
                  goalName = value;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Time Picker for Start Time
            ListTile(
              title: Text(startTime != null
                  ? "Start Time: ${startTime!.format(context)}"
                  : "Pick Start Time"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickStartTime(context),
            ),

            // Time Picker for End Time
            ListTile(
              title: Text(endTime != null
                  ? "End Time: ${endTime!.format(context)}"
                  : "Pick End Time"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickEndTime(context),
            ),

            // Frequency Dropdown
            DropdownButton<String>(
              hint: const Text('Select Frequency'),
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
            const SizedBox(height: 16.0),

            // Frequency Specific Options
            if (frequency == 'Daily')
              Column(
                children: [
                  const Text('Repeat every'),
                  DropdownButton<int>(
                    value: dayInterval,
                    hint: const Text('Day(s)'),
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
                  const Text('Repeat every'),
                  DropdownButton<int>(
                    value: weekInterval,
                    hint: const Text('Week(s)'),
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
                  const Text('On these days'),
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
                  const Text('Repeat every'),
                  DropdownButton<int>(
                    value: monthInterval,
                    hint: const Text('Month(s)'),
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
                  const Text('On day'),
                  DropdownButton<int>(
                    value: selectedDayOfMonth,
                    hint: const Text('Day of Month'),
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
                  const Text('Repeat every'),
                  DropdownButton<int>(
                    value: yearInterval,
                    hint: const Text('Year(s)'),
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
                  const Text('In month'),
                  DropdownButton<String>(
                    value: selectedMonth,
                    hint: const Text('Month'),
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
              trailing: const Icon(Icons.calendar_today),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFECDB),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
