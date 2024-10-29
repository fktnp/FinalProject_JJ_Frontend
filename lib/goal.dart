import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/maingoal.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/custom_button.dart';
import 'model/theme.dart';
import 'taskdetail.dart';
import 'model/mainjobmodel.dart';

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
  String? userId;

  late Future<List<MainJobModel>> futureTasks;

  @override
  void initState() {
    super.initState();
    _readUserIdFromSharedPrefs().then((id) {
      if (id != null) {
        print(id);
        userId = id;
        futureTasks = fetchMainJobModels(); // Call after userId is available
      } else {
        // Handle case where user_id is not found
        print('Error: user_id not found in SharedPreferences');
      }
    });
  }

  Future<List<MainJobModel>> fetchMainJobModels() async {
    if (userId == null) {
      // Handle case where user_id is not available
      throw Exception('user_id is not available');
    }

    final Dio dio = Dio();
    final String url = 'http://10.0.2.2:8080/v1/job/user/$userId';
    final response = await dio.get(url);
    if (userId == null) {
      // Handle case where user_id is not found
      throw Exception('user_id is not available');
    } else if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      print('this is from server : $taskListJson');
      return taskListJson.map((json) => MainJobModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<String?> _readUserIdFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  List<MainJobModel> filterTasks(
      List<MainJobModel> tasks, String? selectedGoal) {
    if (selectedGoal == null) return [];
    return tasks
        .where((task) => task.category == selectedGoal)
        .toList(); // ใช้ category ในการกรอง
  }

  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            selectedGoal == null ? 'Goals' : selectedGoal!,
            style: TextStyle(color: pastel.pastelFont),
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
        color: pastel.pastel2,
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<MainJobModel>>(
            future: futureTasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
                // } else if (snapshot.hasError) {
                //   return Center(child: Text('Error: ${snapshot.error}'));
                // } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // return const Center(child: Text('No tasks found'));
              } else {
                final tasks = snapshot.data ?? [];
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
                                    style: TextStyle(
                                        fontSize: 18, color: pastel.pastelFont),
                                  ),
                                ),
                                backgroundColor: pastel.pastel1,
                                collapsedBackgroundColor: pastel.pastel1,
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
  final MainJobModel task;
  const GoalTask({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.93,
      color: pastel.pastel2,
      child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailPage(mainJobModel: task),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          task.name,
                          style:
                              TextStyle(fontSize: 22, color: pastel.pastelFont),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${task.startTimeGoal.day.toString()}/${task.startTimeGoal.month.toString()}/${task.startTimeGoal.year.toString()} - ${task.lastTimeGoal.day.toString()}/${task.lastTimeGoal.month.toString()}/${task.lastTimeGoal.year.toString()}',
                    style: TextStyle(fontSize: 16, color: pastel.pastelFont),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.07,
                child: CircularPercentIndicator(
                  radius: screenWidth * 0.07,
                  lineWidth: screenWidth * 0.014,
                  percent: task.percentProgress / 100,
                  center: Text('${task.percentProgress.toString()}%'),
                  progressColor: pastel.pastelProgress,
                  backgroundColor: const Color.fromARGB(82, 0, 0, 0),
                ),
              )
            ],
          )),
    );
  }
}

class GoalSection extends StatelessWidget {
  final String goal;
  final List<MainJobModel> tasks;
  final List<MainJobModel> filteredTasks;
  final bool conditionToShowButton;

  const GoalSection({
    super.key,
    required this.goal,
    required this.tasks,
    required this.filteredTasks,
    this.conditionToShowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Stack(
      children: [
        Column(
          children: [
            Card(
              color: pastel.pastel1,
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
                  style: TextStyle(fontSize: 18, color: pastel.pastelFont),
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
              },
            ),
          ),
      ],
    );
  }
}
