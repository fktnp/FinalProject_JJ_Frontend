import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/teamjobmodel.dart';
import 'package:intl/intl.dart';
import 'components/workwithform.dart';
import 'coopsubdetail.dart';
import 'l10n/app_localizations.dart';
import 'model/teamsubjobmodel.dart';
import 'model/theme.dart';
import 'model/usermodel.dart';

class CoopDetailPage extends StatefulWidget {
  final Teamjobmodel teamjobmodel;
  final String loginuserid;

  const CoopDetailPage(
      {super.key, required this.teamjobmodel, required this.loginuserid});
  @override
  CoopDetailPageState createState() => CoopDetailPageState();
}

class CoopDetailPageState extends State<CoopDetailPage> {
  List<String> workByUserIds = [];
  late List<User> participatingUsers;
  List<String> workByUserIdsToSend = [];
  List<String> selectedUserIds = [];
  late String linkWorkArea;
  late String linkSubmitWork;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkWorkAreaController = TextEditingController();
  final TextEditingController linkSubmitWorkController =
      TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime? startDate; // Changed to nullable
  DateTime? lastDate; // Changed to nullable
  TimeOfDay? startTime; // Changed to nullable
  TimeOfDay? lastTime; // Changed to nullable
  late Future<List<Teamsubjobmodel>> futureTasks;
  late String headSubJobId;

  @override
  void initState() {
    super.initState();
    futureTasks =
        fetchTeamSubTasks(); // เรียกใช้ฟังก์ชันนี้ครั้งเดียวใน initState
    participatingUsers = [];
    fetchParticipatingUsers();
  }

  Future<void> fetchParticipatingUsers() async {
    for (String userId in widget.teamjobmodel.workByUserID) {
      User? user = await fetchUserById(userId);
      if (user != null) {
        participatingUsers.add(user);
        workByUserIds.add(userId);
        workByUserIdsToSend.add(userId);
      }
    }
    setState(() {});
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
      } else {
        selectedUserIds.add(userId);
      }
      // อัพเดท workByUserIds ที่เป็น global variable
      workByUserIds = selectedUserIds;
    });
  }

  Future<List<Teamsubjobmodel>> fetchTeamSubTasks() async {
    final Dio dio = Dio();
    final String url =
        'http://10.0.2.2:8080/v1/teamSubJob/subjob/${widget.loginuserid}';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      return taskListJson
          .map((json) => Teamsubjobmodel.fromJson(json))
          .where((task) =>
              task.jobId ==
              widget.teamjobmodel.jobId) // กรองให้ตรงกับ jobId ของ Teamjob
          .toList();
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
            AppLocalizations.of(context).translate('coop'),
            style: TextStyle(color: pastel.pastelFont),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: pastel.pastelFont),
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
                widget.teamjobmodel.name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: pastel.pastelFont),
              ),
              const SizedBox(height: 10),
              Text(
                widget.teamjobmodel.details,
                style: TextStyle(fontSize: 16, color: pastel.pastelFont),
              ),
              const SizedBox(height: 10),
              Text(
                '${AppLocalizations.of(context).translate('date')} : ${widget.teamjobmodel.startDate.day.toString()}/${widget.teamjobmodel.startDate.month.toString()}/${widget.teamjobmodel.startDate.year.toString()} - ${widget.teamjobmodel.lastDate.day.toString()}/${widget.teamjobmodel.lastDate.month.toString()}/${widget.teamjobmodel.lastDate.year.toString()}',
                style: TextStyle(fontSize: 16, color: pastel.pastelFont),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: participatingUsers.map((user) {
                      return Container(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        margin: EdgeInsets.only(left: screenWidth * 0.03),
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
                              color: pastel.participant,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddParticipantPopup(
                            teamjobmodel: widget.teamjobmodel,
                            currentParticipants: workByUserIdsToSend,
                            pastel: pastel,
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: pastel.pastelProgress,
                      foregroundColor: pastel.participant,
                    ),
                    child: Icon(Icons.add, color: pastel.participant),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),

              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: screenHeight,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: pastel.pastel1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FutureBuilder<List<Teamsubjobmodel>>(
                        future: futureTasks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
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
                                    ...tasks
                                        .map((teamSubtask) => CoopSubTaskBox(
                                              teamSubtask: teamSubtask,
                                              userId: widget.loginuserid,
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
              ),
            ],
          ),
        ),
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
      headSubJobId = widget.loginuserid;
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
                const SizedBox(height: 16),
                const Text(
                  'Select Participants:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (participatingUsers.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: participatingUsers.map((user) {
                          final isSelected =
                              selectedUserIds.contains(user.userId);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () => toggleUserSelection(user.userId),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isSelected
                                            ? pastel
                                                .pastelFont // สีเมื่อถูกเลือก
                                            : pastel
                                                .pastel1, // สีเมื่อไม่ถูกเลือก
                                        child: Text(
                                          user.name[0].toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? pastel
                                                    .pastel1 // สีตัวอักษรเมื่อถูกเลือก
                                                : pastel
                                                    .pastelFont, // สีตัวอักษรเมื่อไม่ถูกเลือก
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: pastel.pastelFont,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: 12,
                                              color: pastel.pastel1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: linkWorkAreaController,
                    label: 'Link For Word Area'),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: linkSubmitWorkController,
                    label: 'Link For Submit Work'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastel.pastel1,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      // เมื่อกดปุ่มบันทึก ส่งข้อมูลไปยัง API
                      createSubCoop(
                        jobId: widget.teamjobmodel.jobId,
                        name: nameController.text,
                        status: 'Incomplete',
                        details: detailsController.text,
                        startDate: startDate!,
                        lastDate: lastDate!,
                        startTime: startTime!,
                        lastTime: lastTime!,
                        workByUserIds: workByUserIds,
                        linkWorkArea: linkWorkAreaController.text,
                        linkSubmitWork: linkSubmitWorkController.text,
                        headUserId: headSubJobId,
                      );
                      Navigator.pop(context); // ปิด bottom sheet
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

class CoopSubTaskBox extends StatefulWidget {
  final Teamsubjobmodel teamSubtask;
  final String userId;

  const CoopSubTaskBox({
    super.key,
    required this.teamSubtask,
    required this.userId,
  });

  @override
  _CoopSubTaskBoxState createState() => _CoopSubTaskBoxState();
}

class _CoopSubTaskBoxState extends State<CoopSubTaskBox> {
  late List<User> participatingUsers;

  @override
  void initState() {
    super.initState();
    participatingUsers = [];
    fetchParticipatingUsers();
    print(widget.teamSubtask.subJobId);
  }

  Future<void> fetchParticipatingUsers() async {
    for (String userId in widget.teamSubtask.workByUserID) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoopSubDetailPage(
              teamsubjobmodel: widget.teamSubtask, // ส่งข้อมูล task ที่เลือกไป
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
          color: widget.teamSubtask.status != "Completed"
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
                  widget.teamSubtask.name,
                  style: TextStyle(
                      fontSize: screenWidth * 0.065, color: pastel.pastelFont),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.teamSubtask.startDate.day}/${widget.teamSubtask.startDate.month}/${widget.teamSubtask.startDate.year} - ${widget.teamSubtask.lastDate.day}/${widget.teamSubtask.lastDate.month}/${widget.teamSubtask.lastDate.year}',
                  style: TextStyle(
                      fontSize: screenWidth * 0.035, color: pastel.pastelFont),
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
                            color: pastel.participant,
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
      ),
    );
  }
}
