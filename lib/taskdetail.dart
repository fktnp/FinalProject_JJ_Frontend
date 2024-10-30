import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'components/custom_button.dart';
import 'model/theme.dart';
import 'model/subjobmodel.dart';
import 'subjob.dart';
import 'model/mainjobmodel.dart';

class TaskDetailPage extends StatelessWidget {
  final MainJobModel mainJobModel;
  final String loginuserid;

  const TaskDetailPage(
      {super.key, required this.mainJobModel, required this.loginuserid});

  Future<List<SubJobModel>> fetchSubTasks() async {
    final Dio dio = Dio();
    final String url = 'http://10.0.2.2:8080/v1/subjob/user/$loginuserid';
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

              // แสดงแท็บ
              TabBar(
                tabs: const [
                  SizedBox(
                    width: 120, // ปรับความกว้างของแท็บ Routine
                    child: Tab(text: 'Routine'),
                  ),
                  SizedBox(
                    width: 120, // ปรับความกว้างของแท็บ Goal
                    child: Tab(text: 'Goal'),
                  ),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  color: const Color(
                      0xFFFFDCBC), // เปลี่ยนสีของแท็บที่เลือกเป็นสี FFDCBC
                  borderRadius: BorderRadius.circular(20), // ขอบมนของแท็บ
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      children: [
                        // หน้า Routine
                        Container(
                          width: MediaQuery.of(context).size.width -
                              32, // ความกว้างเต็มหน้าจอ - ระยะขอบ
                          padding: const EdgeInsets.all(16.0),
                          color: const Color(
                              0xFFFFDCBC), // สีพื้นหลังสำหรับ Routine (ถ้าต้องการ)
                          child: ListView.builder(
                            itemCount: 24, // จำนวนชั่วโมง (0-23)
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        8.0), // เพิ่มระยะห่างระหว่างบรรทัด
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // แสดงชั่วโมง
                                    Text(
                                      '${index.toString().padLeft(2, '0')}.00',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: pastel.pastelFont),
                                    ),
                                    // เส้นขีด
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        height:
                                            1, // ความสูงของเส้นขีด (ปรับให้บางลง)
                                        color: Colors.black, // สีของเส้นขีด
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // หน้า Goal
                        Container(
                          // padding: const EdgeInsets.all(16.0),
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
                                final subtask = tasks.where((subtask) =>
                                    (subtask.jobId == mainJobModel.jobId));

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      screenWidth * 0.05,
                                      screenHeight * 0.03,
                                      screenWidth * 0.05,
                                      0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                      ],
                    ),

                    // เพิ่มปุ่มที่มุมขวาล่าง
                    Positioned(
                      bottom: 25,
                      right: 10,
                      child: FixedBottomButton(
                        onPressed: () {
                          AddSubTaskForm(
                                  context: context,
                                  jobId: mainJobModel.jobId,
                                  userId: mainJobModel.userId)
                              .show();
                        },
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
              ? const Color.fromARGB(255, 190, 223, 255)
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
