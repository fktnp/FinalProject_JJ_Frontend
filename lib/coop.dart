import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/model/theme.dart';
import 'package:intl/intl.dart';
import 'coopdetail.dart';
import 'model/teamjobmodel.dart';
import 'model/usermodel.dart';

Future<void> createCoop({
  required String name,
  required String status,
  required String details,
  required DateTime startDate,
  required DateTime lastDate,
  required TimeOfDay startTime,
  required TimeOfDay lastTime,
  required List<String> workByUserIds,
  required String headUserId,
}) async {
  try {
    final Map<String, dynamic> data = {
      'name': name,
      'status': status,
      'details': details,
      'start_date': {
        'day': startDate.day,
        'month': startDate.month,
        'year': startDate.year,
      },
      'last_date': {
        'day': lastDate.day,
        'month': lastDate.month,
        'year': lastDate.year,
      },
      'start_time': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'last_time': {
        'hour': lastTime.hour,
        'minute': lastTime.minute,
      },
      'work_by_user_id': workByUserIds,
      'head_user_id': headUserId,
    };
    var response = await Dio().post(
      'http://10.0.2.2:8080/v1/teamJob',
      data: data,
    );
    // การส่งข้อมูล POST
    print(response.data);
    // print(data);
  } on DioException catch (e) {
    if (e.response != null) {
      print('Error status code: ${e.response?.statusCode}');
      print('Error saving task: ${e.response?.data}');
    } else {
      print('Error sending request: ${e.message}');
    }
  }
}

class CoopPage extends StatefulWidget {
  final String userId;
  const CoopPage({
    super.key,
    required this.userId,
  });

  @override
  _CoopPageState createState() => _CoopPageState();
}

class _CoopPageState extends State<CoopPage> {
  final TextEditingController _participantController = TextEditingController();
  final List<User> _participants = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime? startDate; // Changed to nullable
  DateTime? lastDate; // Changed to nullable
  TimeOfDay? startTime; // Changed to nullable
  TimeOfDay? lastTime; // Changed to nullable
  List<String> workByUserIds = [];
  late Future<List<Teamjobmodel>> futureTasks;

  @override
  void initState() {
    super.initState();
    // ใช้ widget.userId โดยตรงในการ fetch ข้อมูล
    futureTasks = fetchTeamTasks();
  }

  void _addParticipant() async {
    final email = _participantController.text.trim();
    if (email.isNotEmpty) {
      final user = await fetchUserByEmail(email);
      if (user != null) {
        setState(() {
          _participants.add(user);
          // เพิ่ม userId ของ participant ลงใน workByUserIds
          workByUserIds.add(user.userId);
        });
        _participantController.clear();
      } else {
        print('User not found for email: $email');
      }
    }
  }

  Future<List<Teamjobmodel>> fetchTeamTasks() async {
    final Dio dio = Dio();
    final String url = 'http://10.0.2.2:8080/v1/teamJob/job/${widget.userId}';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      print(taskListJson);
      // print(url);
      return taskListJson.map((json) => Teamjobmodel.fromJson(json)).toList();
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
            'Coop',
            style: TextStyle(color: pastel.pastelFont),
          ),
        ),
      ),
      // body: Center(
      body: FutureBuilder<List<Teamjobmodel>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final tasks = snapshot.data ?? [];
            return Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                  screenHeight * 0.03, screenWidth * 0.05, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generate task widgets only once per task
                    // Text(teamTask.userId),
                    ...tasks.map((tasks) => TeamTaskBox(
                          teamtask: tasks,
                          userId: widget.userId,
                        )),
                  ],
                ),
              ),
            );
          }
        },
      ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGoalCoopBottomSheet(context, pastel);
        },
        backgroundColor: pastel.pastel1,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  void _showAddGoalCoopBottomSheet(BuildContext context, Pastel pastel) {
    setState(() {
      workByUserIds = [widget.userId];
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFFFFECDB), // Peach background color
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: pastel.pastel1,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Add a Collective Goal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: pastel.pastelFont,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Fields
                _buildTextField(controller: nameController, label: 'Task Name'),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: detailsController,
                    label: 'Detail',
                    maxLines: 3),
                const SizedBox(height: 20),

                // Date and Time pickers
                _buildDatePickerField('Start Date', startDate, (pickedDate) {
                  setState(() => startDate = pickedDate);
                }),
                const SizedBox(height: 20),
                _buildDatePickerField('Last Date', lastDate, (pickedDate) {
                  setState(() => lastDate = pickedDate);
                }),
                const SizedBox(height: 20),
                _buildTimePicker('Start Time', startTime, (pickedTime) {
                  setState(() => startTime = pickedTime);
                }),
                const SizedBox(height: 20),
                _buildTimePicker('End Time', lastTime, (pickedTime) {
                  setState(() => lastTime = pickedTime);
                }),
                const SizedBox(height: 20),

                // Participants section
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Participants',
                        controller: _participantController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orange),
                      onPressed: _addParticipant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_participants.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Added Participants:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _participants.map((participant) {
                          // แสดงรูปวงกลมที่มีตัวอักษรตัวแรกของชื่อ
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: pastel
                                      .pastel1, // ใช้สีพื้นหลังตามธีมหรือที่กำหนดไว้
                                  child: Text(
                                    participant.name[0]
                                        .toUpperCase(), // ตัวอักษรตัวแรก
                                    style: TextStyle(
                                      color:
                                          pastel.pastelFont, // สีข้อความในรูป
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: 8), // เว้นระยะห่างระหว่างรูปและชื่อ
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Save Button as a '+' Icon
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastel.pastel1,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      // เมื่อกดปุ่มบันทึก ส่งข้อมูลไปยัง API
                      print(startTime);
                      createCoop(
                        name: nameController.text,
                        status: 'In Progress',
                        details: detailsController.text,
                        startDate: startDate!,
                        lastDate: lastDate!,
                        startTime: startTime!,
                        lastTime: lastTime!,
                        workByUserIds: workByUserIds,
                        headUserId: widget.userId,
                      );
                      Navigator.pop(context); // ปิด bottom sheet
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TextField Widget
  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      maxLines: maxLines,
    );
  }

  // DatePicker Widget
  Widget _buildDatePickerField(String label, DateTime? selectedDate,
      ValueChanged<DateTime> onDatePicked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // ชิดซ้าย
        children: [
          Text(label),
          const SizedBox(width: 10), // เพิ่มระยะห่างเล็กน้อย
          TextButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                onDatePicked(pickedDate);
              }
            },
            child: Text(selectedDate == null
                ? 'Pick a date'
                : DateFormat('yyyy-MM-dd').format(selectedDate)),
          ),
        ],
      ),
    );
  }

  // TimePicker Widget
  Widget _buildTimePicker(String label, TimeOfDay? selectedTime,
      ValueChanged<TimeOfDay> onTimePicked) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // ชิดซ้าย
        children: [
          Text(label),
          const SizedBox(width: 10), // เพิ่มระยะห่างเล็กน้อย
          TextButton(
            onPressed: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                onTimePicked(pickedTime);
              }
            },
            child: Text(selectedTime == null
                ? 'Pick a time'
                : selectedTime.format(context)),
          ),
        ],
      ),
    );
  }
}

class TeamTaskBox extends StatefulWidget {
  final Teamjobmodel teamtask;
  final String userId;

  const TeamTaskBox({
    super.key,
    required this.teamtask,
    required this.userId,
  });

  @override
  _TeamTaskBoxState createState() => _TeamTaskBoxState();
}

class _TeamTaskBoxState extends State<TeamTaskBox> {
  late List<User> participatingUsers;

  @override
  void initState() {
    super.initState();
    participatingUsers = [];
    fetchParticipatingUsers();
    print('in the Team Task box now');
  }

  Future<void> fetchParticipatingUsers() async {
    for (String userId in widget.teamtask.workByUserID) {
      User? user = await fetchUserById(userId);
      if (user != null) {
        participatingUsers.add(user);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return GestureDetector(
        onTap: () {
          // เมื่อ TaskBox ถูกกด จะเปลี่ยนไปที่หน้า CoopDetailPage พร้อมส่งข้อมูล
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoopDetailPage(
                teamjobmodel: widget.teamtask, // ส่งข้อมูล task ที่เลือกไป
                loginuserid: widget.userId, // ส่ง userId ไปด้วย
              ),
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.98,
          height: screenHeight * 0.13,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
          decoration: BoxDecoration(
            color: widget.teamtask.status != "Completed"
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
                    widget.teamtask.name,
                    style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        color: pastel.pastelFont),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.teamtask.startDate.day}/${widget.teamtask.startDate.month}/${widget.teamtask.startDate.year} - ${widget.teamtask.lastDate.day}/${widget.teamtask.lastDate.month}/${widget.teamtask.lastDate.year}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: pastel.pastelFont),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: participatingUsers.map((user) {
                      return Container(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: pastel.pastelProgress,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              color: pastel.pastelFont,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ));
  }
}
