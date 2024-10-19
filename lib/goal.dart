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
  late Future<List<Task>> tasksFuture;

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

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  List<Task> filterTasks(List<Task> tasks, String? goal) {
    if (goal == null) return [];
    return tasks.where((task) => task.taskCore == goal).toList();
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
        child: FutureBuilder<List<Task>>(
            future: tasksFuture,
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
                              .where((task) => task.taskCore == goal)
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
                                collapsedBackgroundColor: const Color(0xFFFFDCBC),
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

// class GoalSection extends StatelessWidget {
//   final String goal;
//   final List<Task> tasks;
//   final List<Task> filteredTasks;
//   final bool conditionToShowButton; // Assuming this is a boolean to control button visibility

//   const GoalSection({
//     super.key,
//     required this.goal,
//     required this.tasks,
//     required this.filteredTasks,
//     this.conditionToShowButton = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Column(
//           children: [
//             Card(
//               color: const Color(0xFFFFDCBC),
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
//                 title: Text(
//                   '$goal Planning',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//             if (filteredTasks.isNotEmpty)
//               ...filteredTasks.map((task) => GoalTask(task: task)),
//           ],
//         ),
//         if (conditionToShowButton)
//            Positioned(
//             bottom: 25,
//             right: 10,
//             child: FixedBottomButton(onPressed: () {
//               Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegisterScreen()),
//                   );
//              },
//             ),
//           ),
//       ],
//     );
//   }
// }

class GoalTask extends StatelessWidget {
  final Task task;
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
                    task.taskName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    task.taskDate.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${task.taskStartHour.toString().padLeft(2, '0')}:00 - ${task.taskEndHour.toString().padLeft(2, '0')}:00',
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
  final List<Task> tasks;
  final List<Task> filteredTasks;
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
      isScrollControlled: true, // ให้ pop-up สามารถขยายได้ตามเนื้อหา
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.8, // กำหนดความสูงเป็น 80% ของหน้าจอ
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
                    topRight: Radius.circular(20)),
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
            if (filteredTasks.isNotEmpty)
              ...filteredTasks.map((task) => GoalTask(task: task)),
          ],
        ),
        if (conditionToShowButton)
          Positioned(
            bottom: 25,
            right: 10,
            child: FixedBottomButton(
              onPressed: () {
                AddFromGoal(context: context, goal: goal).show();
                 //showGoalAddBottomSheet(context)ของเพิ่มย่อย
                // AddFromGoal(context: context, goal: goal).show(); ของอันหลัก
                // เรียกใช้ฟังก์ชัน showOverlay
              },
            ),
          ),
      ],
    );
  }
}