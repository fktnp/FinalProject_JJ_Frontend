import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'model/theme.dart';
import 'model/subjobmodel.dart';
import 'components/subjobform.dart';
import 'model/mainjobmodel.dart';

class TaskDetailPage extends StatelessWidget {
  final MainJobModel mainJobModel;
  final String loginuserid;

  const TaskDetailPage(
      {super.key, required this.mainJobModel, required this.loginuserid});

  Future<List<SubJobModel>> fetchSubTasks() async {
    final Dio dio = Dio();
    final String url = 'http://192.168.1.36:8080/v1/subjob/user/$loginuserid';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      return taskListJson.map((json) => SubJobModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      backgroundColor: pastel.pastel2,
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Goal',
            style: TextStyle(color: pastel.pastelFont),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 2, // จำนวนแท็บ
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แสดงชื่อของเป้าหมาย
              Text(
                mainJobModel.name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: pastel.pastelFont),
              ),
              const SizedBox(height: 10),
              Text(
                'Date : ${mainJobModel.startTimeGoal.day.toString()}/${mainJobModel.startTimeGoal.month.toString()}/${mainJobModel.startTimeGoal.year.toString()} - ${mainJobModel.lastTimeGoal.day.toString()}/${mainJobModel.lastTimeGoal.month.toString()}/${mainJobModel.lastTimeGoal.year.toString()}',
                style: TextStyle(fontSize: 16, color: pastel.pastelFont),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Stack(
                  children: [
                    // หน้า Goal
                    Container(
                      height: screenHeight,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: pastel.pastel1, // สีพื้นหลัง
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FutureBuilder<List<SubJobModel>>(
                        future: fetchSubTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            final tasks = snapshot.data ?? [];
                            print(tasks);
                            final subtask = tasks.where((subtask) =>
                                (subtask.jobId == mainJobModel.jobId));

                            return Padding(
                              padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                                  screenHeight * 0.03, screenWidth * 0.05, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Generate task widgets only once per task
                                    ...subtask.map((subtask) => SubTaskBox(
                                          subtask: subtask,
                                        )),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      right: 10,
                      child: FloatingActionButton(
                        onPressed: () {
                          AddSubTaskForm(
                                  context: context,
                                  jobId: mainJobModel.jobId,
                                  userId: mainJobModel.userId)
                              .show();
                        },
                        backgroundColor: pastel.pastelFont,
                        child: Icon(Icons.add, color: pastel.pastel1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubTaskBox extends StatelessWidget {
  final SubJobModel subtask;

  const SubTaskBox({
    super.key,
    required this.subtask,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
        width: screenWidth * 0.98,
        height: screenHeight * 0.11,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
        decoration: BoxDecoration(
          color: subtask.percentProgress < 100
              ? pastel.pastelBlock
              : const Color.fromARGB(255, 190, 255, 201),
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtask.name,
                  style: TextStyle(
                      fontSize: screenWidth * 0.065, color: pastel.pastelFont),
                ),
                const SizedBox(height: 5),
                // Show the start and end date in one line
                Text(
                  '${subtask.startDate.day}/${subtask.startDate.month}/${subtask.startDate.year} - ${subtask.lastDate.day}/${subtask.lastDate.month}/${subtask.lastDate.year}',
                  style: TextStyle(
                      fontSize: screenWidth * 0.035, color: pastel.pastelFont),
                ),
              ],
            ),
            CircularPercentIndicator(
              radius: screenWidth * 0.07,
              lineWidth: screenWidth * 0.014,
              percent: subtask.percentProgress / 100,
              center: Text('${subtask.percentProgress.toString()}%'),
              progressColor: pastel.pastelProgress,
              backgroundColor: const Color.fromARGB(82, 0, 0, 0),
            ),
          ],
        ));
  }
}