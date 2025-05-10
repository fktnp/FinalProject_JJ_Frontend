import 'package:flutter/material.dart';
import 'components/custom_button.dart';
import 'subjob.dart';
import 'task.dart';

class TaskDetailPage extends StatelessWidget {
  final MainTask task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFECDB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCBC),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Goal',
            style: TextStyle(color: Colors.black),
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
                task.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Date : ${task.startTimeGoal.day.toString()}/${task.startTimeGoal.month.toString()}/${task.startTimeGoal.year.toString()} - ${task.lastTimeGoal.day.toString()}/${task.lastTimeGoal.month.toString()}/${task.lastTimeGoal.year.toString()}',
                style: const TextStyle(fontSize: 16),
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
                                      style: const TextStyle(fontSize: 16),
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
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDCBC), // สีพื้นหลัง
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goal Details', // เพิ่มรายละเอียด Goal ที่นี่
                                style: TextStyle(fontSize: 20),
                              ),
                              // เพิ่มข้อมูลอื่นๆ เกี่ยวกับ Goal ที่นี่
                            ],
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
                          AddSubTaskForm(context: context, jobId: task.jobId, userId: task.userId)
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