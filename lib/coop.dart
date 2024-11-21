import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'coopdetail.dart';
import 'l10n/app_localizations.dart';
import 'model/teamjobmodel.dart';
import 'model/usermodel.dart';

Future<void> createCoop({
  required BuildContext context,
  required String name,
  required String status,
  required String details,
  required DateTime startDate,
  required DateTime lastDate,
  required TimeOfDay startTime,
  required TimeOfDay lastTime,
  required List<String> workByUserIds,
  required String headUserId,
  required VoidCallback onTaskCreated, // เพิ่ม callback เพื่อรีเฟรชข้อมูล
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
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;

    var response = await Dio().post(
      '$apiUrl/v1/teamJob',
      data: data,
    );
    print(response.data);

    // เรียก callback หลังสร้างงานสำเร็จ
    onTaskCreated();
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
      final user = await fetchUserByEmail(email, context);
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
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/teamJob/job/${widget.userId}';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      print(apiUrl);
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
          alignment: Alignment.center,
          child: Text(
            overflow: TextOverflow.ellipsis,
            AppLocalizations.of(context).translate('coop'),
            style: TextStyle(
                color: pastel.pastelFont, fontWeight: FontWeight.bold),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGoalCoopBottomSheet(context, pastel);
        },
        backgroundColor: pastel.pastelFont,
        child: Icon(Icons.add, color: pastel.pastel1),
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
      backgroundColor: pastel.pastel2, // Peach background color
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
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
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
                _buildTextField(
                    controller: nameController,
                    label: AppLocalizations.of(context).translate('task_name')),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: detailsController,
                    label: AppLocalizations.of(context).translate('details'),
                    maxLines: 3),
                const SizedBox(height: 20),

                // Date and Time pickers
                _buildDatePickerField(
                    AppLocalizations.of(context)
                        .translate('start')
                        .replaceFirst('{text}',
                            AppLocalizations.of(context).translate('day')),
                    startDate, (pickedDate) {
                  setState(() => startDate = pickedDate);
                }),
                const SizedBox(height: 20),
                _buildDatePickerField(
                    AppLocalizations.of(context).translate('end').replaceFirst(
                        '{text}',
                        AppLocalizations.of(context).translate('day')),
                    lastDate, (pickedDate) {
                  setState(() => lastDate = pickedDate);
                }),
                const SizedBox(height: 20),
                _buildTimePicker(
                    AppLocalizations.of(context)
                        .translate('start')
                        .replaceFirst('{text}',
                            AppLocalizations.of(context).translate('time')),
                    startTime, (pickedTime) {
                  setState(() => startTime = pickedTime);
                }),
                const SizedBox(height: 20),
                _buildTimePicker(
                    AppLocalizations.of(context).translate('end').replaceFirst(
                        '{text}',
                        AppLocalizations.of(context).translate('time')),
                    lastTime, (pickedTime) {
                  setState(() => lastTime = pickedTime);
                }),
                const SizedBox(height: 20),

                // Participants section
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label:
                            '${AppLocalizations.of(context).translate('email_of')} ${AppLocalizations.of(context).translate('participants')}',
                        controller: _participantController,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: pastel.pastelFont),
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
                        overflow: TextOverflow.ellipsis,
                        'Added Participants:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _participants.map((participant) {
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
                                    overflow: TextOverflow.ellipsis,
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
                      if (nameController.text.isNotEmpty &&
                          startDate != null &&
                          lastDate != null &&
                          startTime != null &&
                          lastTime != null) {
                        createCoop(
                          context: context,
                          name: nameController.text,
                          status: 'In Progress',
                          details: detailsController.text,
                          startDate: startDate!,
                          lastDate: lastDate!,
                          startTime: startTime!,
                          lastTime: lastTime!,
                          workByUserIds: workByUserIds,
                          headUserId: widget.userId,
                          onTaskCreated: () {
                            // อัปเดต futureTasks และรีเฟรช UI
                            setState(() {
                              futureTasks = fetchTeamTasks();
                            });
                          },
                        );
                        Navigator.pop(context); // ปิด Bottom Sheet
                      } else {
                        print('กรุณากรอกข้อมูลให้ครบถ้วน');
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color: pastel.pastelProgress,
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: pastel.pastel1,
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: pastel.pastel1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // ชิดซ้าย
        children: [
          Icon(
            Icons.calendar_today,
            color: pastel.pastelFont,
          ),
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
            child: Text(
                overflow: TextOverflow.ellipsis,
                selectedDate == null
                    ? label
                    : DateFormat('yyyy-MM-dd').format(selectedDate)),
          ),
        ],
      ),
    );
  }

  // TimePicker Widget
  Widget _buildTimePicker(String label, TimeOfDay? selectedTime,
      ValueChanged<TimeOfDay> onTimePicked) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: pastel.pastel1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // ชิดซ้าย
        children: [
          Icon(
            Icons.timer,
            color: pastel.pastelFont,
          ),
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
            child: Text(
                overflow: TextOverflow.ellipsis,
                selectedTime == null ? label : selectedTime.format(context)),
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
      User? user = await fetchUserById(userId, context);
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
                    overflow: TextOverflow.ellipsis,
                    widget.teamtask.name,
                    style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        color: pastel.pastelFont),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    '${widget.teamtask.startDate.day}/${widget.teamtask.startDate.month}/${widget.teamtask.startDate.year} - ${widget.teamtask.lastDate.day}/${widget.teamtask.lastDate.month}/${widget.teamtask.lastDate.year}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: pastel.pastelFont),
                  ),
                  const SizedBox(height: 5),
                  SingleChildScrollView(
                    child: Row(
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
                              overflow: TextOverflow.ellipsis,
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '',
                              style: TextStyle(
                                color: pastel.participant,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ));
  }
}
