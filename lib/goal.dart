import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/maingoal.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'model/theme.dart';
import 'taskdetail.dart';
import 'model/mainjobmodel.dart';

class GoalsPage extends StatefulWidget {
  final String userId; // เพิ่ม userId parameter

  const GoalsPage({
    super.key,
    required this.userId, // รับ userId จาก constructor
  });

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
  Future<List<MainJobModel>> futureTasks = Future.value([]);

  void _onTaskAdded() {
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      futureTasks = fetchMainJobModels();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<List<MainJobModel>> fetchMainJobModels() async {
    final Dio dio = Dio();
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/job/user/${widget.userId}';
    try {
      final response = await dio.get(url);

      // ตรวจสอบว่า response.data ไม่เป็น null และเป็น List
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> taskListJson = response.data;
        print('this is from server : $taskListJson');
        return taskListJson.map((json) => MainJobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    // final screenHeight = mediaQuery.size.height;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        centerTitle: true,
        title: Text(
          overflow: TextOverflow.ellipsis,
          AppLocalizations.of(context).translate('goals'),
          style:
              TextStyle(color: pastel.pastelFont, fontWeight: FontWeight.bold),
        ),
        // แสดงปุ่มย้อนกลับเสมอเมื่อ selectedGoal ไม่เป็น null
        leading: selectedGoal != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: pastel.pastelFont),
                onPressed: () {
                  setState(() {
                    selectedGoal =
                        null; // ตั้ง selectedGoal เป็น null เพื่อกลับไปหน้า GoalsPage
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
                } else {
                  final tasks = snapshot.data ?? [];
                  return selectedGoal == null
                      ? ListView.builder(
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            // ดึงข้อความแปลตาม goal ปัจจุบัน
                            String goalTranslation;
                            switch (goal) {
                              case 'Health':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('health');
                                break;
                              case 'Financial':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('financial');
                                break;
                              case 'Career':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('career');
                                break;
                              case 'Family':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('family');
                                break;
                              case 'Social':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('social');
                                break;
                              case 'Leisure':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('leisure');
                                break;
                              case 'Friendship':
                                goalTranslation = AppLocalizations.of(context)
                                    .translate('friendship');
                                break;
                              default:
                                goalTranslation = goal;
                            }
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
                                      overflow: TextOverflow.ellipsis,
                                      AppLocalizations.of(context)
                                          .translate('planing')
                                          .replaceFirst(
                                              '{goal}', goalTranslation),
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          color: pastel.pastelFont),
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
                                          .map((task) => GoalTask(
                                                task: task,
                                                loginuserid: widget.userId,
                                              ))
                                          .toList()
                                      : [
                                          const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                                overflow: TextOverflow.ellipsis,
                                                'No tasks available'),
                                          ),
                                        ],
                                ),
                              ),
                            );
                          },
                        )
                      : GoalSection(
                          goal: selectedGoal!,
                          loginuserid: widget.userId,
                          onTaskAdded: _onTaskAdded,
                        );
                }
              })),
    );
  }
}

class GoalTask extends StatelessWidget {
  final String loginuserid;
  final MainJobModel task;
  const GoalTask({super.key, required this.task, required this.loginuserid});

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
                          builder: (context) => TaskDetailPage(
                              mainJobModel: task, loginuserid: loginuserid),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overflow: TextOverflow.ellipsis,
                          task.name,
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: pastel.pastelFont),
                        ),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          '${task.startTimeGoal.day.toString()}/${task.startTimeGoal.month.toString()}/${task.startTimeGoal.year.toString()} - ${task.lastTimeGoal.day.toString()}/${task.lastTimeGoal.month.toString()}/${task.lastTimeGoal.year.toString()}',
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: pastel.pastelFont),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.07,
                child: CircularPercentIndicator(
                  radius: screenWidth * 0.07,
                  lineWidth: screenWidth * 0.014,
                  percent: task.percentProgress / 100,
                  center: Text(
                      overflow: TextOverflow.ellipsis,
                      '${task.percentProgress.toString()}%'),
                  progressColor: pastel.pastelProgress,
                  backgroundColor: const Color.fromARGB(82, 0, 0, 0),
                ),
              )
            ],
          )),
    );
  }
}

class GoalSection extends StatefulWidget {
  final String goal;
  final String loginuserid;
  final bool conditionToShowButton;
  final VoidCallback onTaskAdded;

  const GoalSection({
    super.key,
    required this.goal,
    required this.loginuserid,
    required this.onTaskAdded,
    this.conditionToShowButton = true,
  });

  @override
  State<GoalSection> createState() => _GoalSectionState();
}

class _GoalSectionState extends State<GoalSection> {
  List<MainJobModel> tasks = [];
  bool isLoading = true; // สำหรับแสดงสถานะการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _refreshTasks(); // โหลดข้อมูลเมื่อเริ่มต้น
  }

  Future<void> _refreshTasks() async {
    setState(() {
      isLoading = true; // แสดงสถานะการโหลด
    });

    try {
      final newTasks = await fetchMainJobModels();
      setState(() {
        tasks = filterTasks(newTasks, widget.goal);
      });
    } catch (e) {
      print('Error refreshing tasks: $e');
    } finally {
      setState(() {
        isLoading = false; // ซ่อนสถานะการโหลด
      });
    }
  }

  Future<List<MainJobModel>> fetchMainJobModels() async {
    final Dio dio = Dio();
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/job/user/${widget.loginuserid}';
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> taskListJson = response.data;
        return taskListJson.map((json) => MainJobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  List<MainJobModel> filterTasks(
      List<MainJobModel> tasks, String selectedGoal) {
    return tasks.where((task) => task.category == selectedGoal).toList();
  }

  String _getGoalTranslation(String goal) {
    switch (goal) {
      case 'Health':
        return AppLocalizations.of(context).translate('health');
      case 'Financial':
        return AppLocalizations.of(context).translate('financial');
      case 'Career':
        return AppLocalizations.of(context).translate('career');
      case 'Family':
        return AppLocalizations.of(context).translate('family');
      case 'Social':
        return AppLocalizations.of(context).translate('social');
      case 'Leisure':
        return AppLocalizations.of(context).translate('leisure');
      case 'Friendship':
        return AppLocalizations.of(context).translate('friendship');
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    final goalTranslation = _getGoalTranslation(widget.goal);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Stack(
      children: [
        Column(
          children: [
            Card(
              color: pastel.pastel1,
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
                  overflow: TextOverflow.ellipsis,
                  AppLocalizations.of(context)
                      .translate('planing')
                      .replaceFirst('{goal}', goalTranslation),
                  style: TextStyle(
                      fontSize: screenWidth * 0.05, color: pastel.pastelFont),
                ),
              ),
            ),
            if (isLoading)
              const CircularProgressIndicator(), // แสดง Loading Indicator
            if (!isLoading && tasks.isNotEmpty)
              ...tasks.map((task) => GoalTask(
                    task: task,
                    loginuserid: widget.loginuserid,
                  )),
            if (!isLoading && tasks.isEmpty)
              const Text('No tasks available for this goal.'), // กรณีไม่มี task
          ],
        ),
        if (widget.conditionToShowButton)
          Positioned(
            bottom: 25,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                AddFromGoal(
                  context: context,
                  goal: widget.goal,
                  loginuserid: widget.loginuserid,
                ).show(() async {
                  await _refreshTasks(); // โหลดข้อมูลใหม่เมื่อเพิ่มสำเร็จ
                });
              },
              backgroundColor: pastel.pastelFont,
              child: Icon(Icons.add, color: pastel.pastel1),
            ),
          ),
      ],
    );
  }
}
