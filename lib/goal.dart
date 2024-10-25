import 'package:flutter/material.dart';
import 'package:flutter_application_1/maingoal.dart';
import 'components/custom_button.dart';
import 'taskdetail.dart';
import 'task.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<String> goals = [
    'Health',
    'Financial',
    'Career',
    'Family',
    'Social',
    'Leisure',
    'Friendship',
  ];

  String? selectedGoal;

  late Future<List<ServerTask>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasks(); // ดึงข้อมูลจาก API เมื่อหน้าเริ่มต้น
  }

  List<ServerTask> filterTasks(List<ServerTask> tasks, String? selectedGoal) {
    if (selectedGoal == null) return [];
    return tasks
        .where((task) => task.category == selectedGoal)
        .toList(); // ใช้ category ในการกรอง
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCBC),
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            selectedGoal == null ? 'Goals' : selectedGoal!,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        automaticallyImplyLeading: selectedGoal != null,
        leading: selectedGoal != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    selectedGoal = null; // Reset selected goal
                  });
                },
              )
            : null,
      ),
      body: Container(
        color: const Color(0xFFFFECDB),
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<ServerTask>>(
            future: futureTasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks found'));
              } else {
                final tasks = snapshot.data!;
                final filteredTasks = filterTasks(tasks, selectedGoal);

                return selectedGoal == null
                    ? ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          final showTask = tasks
                              .where((task) => task.category == goal)
                              .toList();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: ExpansionTile(
                                title: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGoal = goal;
                                    });
                                  },
                                  child: Text(
                                    '$goal Planning',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                backgroundColor: const Color(0xFFFFDCBC),
                                collapsedBackgroundColor:
                                    const Color(0xFFFFDCBC),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                collapsedShape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                children: showTask.isNotEmpty
                                    ? showTask
                                        .map((task) => GoalTask(task: task))
                                        .toList()
                                    : [
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('No tasks available'),
                                        ),
                                      ],
                              ),
                            ),
                          );
                        },
                      )
                    : GoalSection(
                        goal: selectedGoal!,
                        tasks: tasks,
                        filteredTasks: filteredTasks,
                      );
              }
            }),
      ),
    );
  }
}

class GoalTask extends StatelessWidget {
  final ServerTask task;
  const GoalTask({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.93,
      color: const Color.fromARGB(255, 251, 197, 255),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(task: task),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Text(
              '${task.startTimeGoal.day.toString()}/${task.startTimeGoal.month.toString()}/${task.startTimeGoal.year.toString()} - ${task.lastTimeGoal.day.toString()}/${task.lastTimeGoal.month.toString()}/${task.lastTimeGoal.year.toString()}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalSection extends StatelessWidget {
  final String goal;
  final List<ServerTask> tasks;
  final List<ServerTask> filteredTasks;
  final bool conditionToShowButton;

  const GoalSection({
    super.key,
    required this.goal,
    required this.tasks,
    required this.filteredTasks,
    this.conditionToShowButton = true,
  });

  void showGoalAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: GoaladdPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Card(
              color: const Color(0xFFFFDCBC),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                title: Text(
                  '$goal Planning',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            // แสดง filtered tasks
            if (filteredTasks.isNotEmpty)
              ...filteredTasks.map((task) => GoalTask(task: task)).toList(),
          ],
        ),
        // ปุ่มที่ถูกจัดตำแหน่ง
        if (conditionToShowButton)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FixedBottomButton(
                onPressed: () {
                  AddFromGoal(context: context, goal: goal).show();
                },
              ),
            ),
          ),
      ],
    );
  }
}

