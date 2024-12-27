import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/teamjobmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'components/workwithform.dart';
import 'coopsubdetail.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'model/teamsubjobmodel.dart';
import 'model/theme.dart';
import 'model/usermodel.dart';

class CoopDetailPage extends StatefulWidget {
  final String loginuserid;
  final String jobId; // Change from teamjobmodel to specific jobId

  const CoopDetailPage(
      {super.key, required this.loginuserid, required this.jobId});

  @override
  CoopDetailPageState createState() => CoopDetailPageState();
}

class CoopDetailPageState extends State<CoopDetailPage> {
  late List<User> participatingUsers;
  List<String> selectedUserIds = [];
  late Teamjobmodel teamjobmodel;
  late bool isLoading = true;
  late String linkWorkArea;
  late String linkSubmitWork;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkWorkAreaController = TextEditingController();
  final TextEditingController linkSubmitWorkController =
      TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime? startDate;
  DateTime? lastDate;
  TimeOfDay? startTime;
  TimeOfDay? lastTime;
  late Future<List<Teamsubjobmodel>> futureTasks;
  late String headSubJobId;
  late Future<Teamjobmodel> teamJobFuture;

  @override
  void initState() {
    super.initState();
    selectedUserIds = [];
    _loadTeamJobData();
    futureTasks = fetchTeamSubTasks();
  }

  Future<void> _loadTeamJobData() async {
    try {
      // First, fetch the team job details
      final Dio dio = Dio();
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
      final String url = '$apiUrl/v1/teamJob/${widget.jobId}';

      final response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          teamjobmodel = Teamjobmodel.fromJson(response.data);
          isLoading = false;
        });

        // Then fetch participating users
        await fetchParticipatingUsers();
      } else {
        throw Exception('Failed to load team job details');
      }
    } catch (e) {
      print('Error loading team job data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchParticipatingUsers() async {
    participatingUsers = [];
    for (String userId in teamjobmodel.workByUserID) {
      User? user = await fetchUserById(userId, context);
      if (user != null) {
        participatingUsers.add(user);
      }
    }
    setState(() {});
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
        print("Remove : $userId");
      } else {
        selectedUserIds.add(userId);
        print("This is Selected user : $selectedUserIds");
      }
    });
  }

  Future<List<Teamsubjobmodel>> fetchTeamSubTasks() async {
    final Dio dio = Dio();
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/teamSubJob/subjob/${widget.loginuserid}';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> taskListJson = response.data;
      return taskListJson
          .map((json) => Teamsubjobmodel.fromJson(json))
          .where((task) =>
              task.jobId == widget.jobId) // กรองให้ตรงกับ jobId ของ Teamjob
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

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        backgroundColor: pastel.pastel2,
        appBar: AppBar(
          backgroundColor: pastel.pastel1,
          title: Text(
            overflow: TextOverflow.ellipsis,
            AppLocalizations.of(context).translate('coop'),
            style: TextStyle(
                color: pastel.pastelFont, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          teamjobmodel.name,
                          style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: pastel.pastelFont),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.block_sharp),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context,
                            'teamJob',
                            teamjobmodel.jobId,
                            'coop',
                            widget.loginuserid,
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    teamjobmodel.details,
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: pastel.pastelFont),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    '${AppLocalizations.of(context).translate('date')} : ${teamjobmodel.startDate.day.toString()}/${teamjobmodel.startDate.month.toString()}/${teamjobmodel.startDate.year.toString()} - ${teamjobmodel.lastDate.day.toString()}/${teamjobmodel.lastDate.month.toString()}/${teamjobmodel.lastDate.year.toString()}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: pastel.pastelFont),
                  ),
                  Row(
                    children: [
                      Row(
                        children: participatingUsers.map((user) {
                          return Container(
                            width: screenWidth * 0.09,
                            height: screenWidth * 0.09,
                            margin: EdgeInsets.only(left: screenWidth * 0.02),
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
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      widget.loginuserid == teamjobmodel.headUserID
                          ? ElevatedButton(
                              onPressed: () async {
                                final bool? hasUpdated = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddParticipantPopup(
                                      teamjobmodel: teamjobmodel,
                                      currentParticipants:
                                          teamjobmodel.workByUserID,
                                      pastel: pastel,
                                    );
                                  },
                                );
                                if (hasUpdated == true) {
                                  // รีเฟรชข้อมูลผู้เข้าร่วมงาน
                                  await fetchParticipatingUsers();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pastel.pastelProgress,
                                foregroundColor: pastel.participant,
                              ),
                              child: Icon(Icons.add, color: pastel.participant),
                            )
                          : const SizedBox()
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
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
                              } else if (snapshot.hasData) {
                                final tasks = snapshot.data!;
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
                                        ...tasks.map(
                                            (teamSubtask) => CoopSubTaskBox(
                                                  allParticipants:
                                                      participatingUsers,
                                                  teamSubtask: teamSubtask,
                                                  userId: widget.loginuserid,
                                                  teamjobmodel: teamjobmodel,
                                                )),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(child: Text(''));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        floatingActionButton: widget.loginuserid == teamjobmodel.headUserID
            ? FloatingActionButton(
                onPressed: () {
                  _showAddGoalCoopBottomSheet(
                    context,
                    pastel,
                  );
                },
                backgroundColor: pastel.pastelFont,
                child: Icon(Icons.add, color: pastel.pastel1),
              )
            : const SizedBox());
  }

  void _showAddGoalCoopBottomSheet(
    BuildContext context,
    Pastel pastel,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: pastel.pastel1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    AppLocalizations.of(context)
                        .translate('add_goal')
                        .replaceFirst('{text}',
                            AppLocalizations.of(context).translate('main')),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: pastel.pastelFont,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.0135),

                    // Fields
                    _buildTextField(
                        controller: nameController,
                        label: AppLocalizations.of(context)
                            .translate('task_name')),
                    SizedBox(height: screenHeight * 0.0135),
                    _buildTextField(
                        controller: detailsController,
                        label:
                            AppLocalizations.of(context).translate('details'),
                        maxLines: 3),
                    SizedBox(height: screenHeight * 0.0135),

                    // Date and Time pickers
                    _buildDatePickerField(
                        AppLocalizations.of(context)
                            .translate('start')
                            .replaceFirst('{text}',
                                AppLocalizations.of(context).translate('day')),
                        startDate, (pickedDate) {
                      setState(() => startDate = pickedDate);
                    }),
                    SizedBox(height: screenHeight * 0.0135),
                    _buildDatePickerField(
                        AppLocalizations.of(context)
                            .translate('end')
                            .replaceFirst('{text}',
                                AppLocalizations.of(context).translate('day')),
                        lastDate, (pickedDate) {
                      setState(() => lastDate = pickedDate);
                    }),
                    SizedBox(height: screenHeight * 0.0135),
                    _buildTimePicker(
                        AppLocalizations.of(context)
                            .translate('start')
                            .replaceFirst('{text}',
                                AppLocalizations.of(context).translate('time')),
                        startTime, (pickedTime) {
                      setState(() => startTime = pickedTime);
                    }),
                    SizedBox(height: screenHeight * 0.0135),
                    _buildTimePicker(
                        AppLocalizations.of(context)
                            .translate('end')
                            .replaceFirst('{text}',
                                AppLocalizations.of(context).translate('time')),
                        lastTime, (pickedTime) {
                      setState(() => lastTime = pickedTime);
                    }),
                    SizedBox(height: screenHeight * 0.0125),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      '${AppLocalizations.of(context).translate('select_participants')} :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    if (participatingUsers.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Row(
                                children: participatingUsers.map((user) {
                                  final isSelected =
                                      selectedUserIds.contains(user.userId);

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.008),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleUserSelection(user.userId);
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: screenWidth * 0.06,
                                                backgroundColor: isSelected
                                                    ? pastel.pastelFont
                                                    : pastel.pastel1,
                                                child: Text(
                                                  user.name[0].toUpperCase(),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? pastel.pastel1
                                                        : pastel.pastelFont,
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: pastel.pastelFont,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: screenWidth * 0.035,
                                                      color: pastel.pastel1,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? pastel.pastelFont
                                                  : pastel.pastelFont,
                                              fontSize: screenWidth * 0.04,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),

                    SizedBox(height: screenHeight * 0.0135),
                    _buildTextField(
                        controller: linkWorkAreaController,
                        label: AppLocalizations.of(context)
                            .translate('work_link')),
                    SizedBox(height: screenHeight * 0.0135),
                    _buildTextField(
                        controller: linkSubmitWorkController,
                        label: AppLocalizations.of(context)
                            .translate('submit_link')),
                    SizedBox(height: screenHeight * 0.0135),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pastel.pastel1,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: () {
                          createSubCoop(
                            context: context,
                            jobId: teamjobmodel.jobId,
                            name: nameController.text,
                            status: 'Incomplete',
                            details: detailsController.text,
                            startDate: startDate!,
                            lastDate: lastDate!,
                            startTime: startTime!,
                            lastTime: lastTime!,
                            workByUserIds: selectedUserIds,
                            linkWorkArea: linkWorkAreaController.text,
                            linkSubmitWork: linkSubmitWorkController.text,
                            headUserId: headSubJobId,
                          ).then((_) {
                            // Refresh the tasks after creating a new subtask
                            setState(() {
                              futureTasks = fetchTeamSubTasks();
                            });
                          });
                          Navigator.pop(context); // Close bottom sheet
                        },
                        child: Icon(
                          Icons.check,
                          color: pastel.pastelFont,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            Icons.calendar_today,
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

class CoopSubTaskBox extends StatefulWidget {
  final List<User> allParticipants;
  final Teamsubjobmodel teamSubtask;
  final String userId;
  final Teamjobmodel teamjobmodel;

  const CoopSubTaskBox({
    super.key,
    required this.teamSubtask,
    required this.userId,
    required this.allParticipants,
    required this.teamjobmodel,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoopSubDetailPage(
              teamsubjobmodel: widget.teamSubtask, // ส่งข้อมูล task ที่เลือกไป
              loginuserid: widget.userId, // ส่ง userId ไปด้วย
              allParticipants: widget.allParticipants,
              teamjobmodel: widget.teamjobmodel,
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
                  overflow: TextOverflow.ellipsis,
                  widget.teamSubtask.name,
                  style: TextStyle(
                      fontSize: screenWidth * 0.065, color: pastel.pastelFont),
                ),
                const SizedBox(height: 5),
                Text(
                  overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 5),
              ],
            ),
            Icon(
                size: screenWidth * 0.1,
                widget.teamSubtask.status == 'Incomplete'
                    ? Icons.hourglass_empty
                    : Icons.check_circle,
                color: pastel.pastelFont),
          ],
        ),
      ),
    );
  }
}
