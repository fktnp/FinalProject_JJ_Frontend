import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/teamjobmodel.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../model/teamsubjobmodel.dart';
import '../model/theme.dart';
import '../model/usermodel.dart';

class AddParticipantPopup extends StatefulWidget {
  final Teamjobmodel teamjobmodel;
  final List<String> currentParticipants;
  final Pastel pastel;

  const AddParticipantPopup({
    super.key,
    required this.currentParticipants,
    required this.pastel,
    required this.teamjobmodel,
  });

  @override
  _AddParticipantPopupState createState() => _AddParticipantPopupState();
}

class _AddParticipantPopupState extends State<AddParticipantPopup> {
  final _emailController = TextEditingController();
  List<String> workByUserIds = [];

  Future<void> _updateParticipantsInTeamJob(String userId) async {
    final data = {
      "work_by_user_id":
          widget.currentParticipants, // สมมติว่าส่งรายชื่อทั้งหมดไปอัปเดต
    };

    try {
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
      final response = await Dio().put(
        '$apiUrl/v1/teamJob/${widget.teamjobmodel.jobId}',
        data: data,
      );

      // เช็คว่าอัปเดตสำเร็จหรือไม่
      if (response.statusCode == 200) {
        print('Update successful');
      } else {
        print('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  void onParticipantAdded(String userId) async {
    // เพิ่มผู้ใช้งานใน currentParticipants
    setState(() {
      widget.currentParticipants.add(userId);
    });

    // อัปเดตไปยัง server
    await _updateParticipantsInTeamJob(userId);

    // ปิด popup และรีเฟรชข้อมูลบนหน้า
    if (mounted) {
      Navigator.pop(context, true); // ปิด popup

      // หลังจากปิดหน้า dialog, สามารถรีเฟรชหน้าหลักด้วย setState
      setState(() {
        // รีเซ็ตหน้าหลักหรือโหลดข้อมูลใหม่ถ้าต้องการ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        overflow: TextOverflow.ellipsis,
        'Add a Participant',
        style: TextStyle(
          color: widget.pastel.pastelFont,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter participant email',
              hintStyle: TextStyle(color: widget.pastel.pastelFont),
            ),
            style: TextStyle(color: widget.pastel.pastelFont),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final email = _emailController.text.trim();
              if (email.isNotEmpty &&
                  !widget.currentParticipants.contains(email)) {
                final User? newUser = await fetchUserByEmail(email, context);
                if (newUser != null) {
                  onParticipantAdded(newUser.userId);
                }
              }
            },
            child:
                const Text(overflow: TextOverflow.ellipsis, 'Add Participant'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose(); // ปิดตัวควบคุม TextController ที่ไม่ใช้
    super.dispose();
  }
}

class SelectParticipantsWidget extends StatefulWidget {
  final Teamsubjobmodel teamsubJobmodel;
  final List<User> participatingUsers;
  final List<String> selectedUserIds;
  final Function(String) onToggleUserSelection;
  final Pastel pastel;
  final BuildContext context;

  const SelectParticipantsWidget({
    super.key,
    required this.participatingUsers,
    required this.selectedUserIds,
    required this.onToggleUserSelection,
    required this.pastel,
    required this.teamsubJobmodel,
    required this.context,
  });

  @override
  _SelectParticipantsWidgetState createState() =>
      _SelectParticipantsWidgetState();
}

class _SelectParticipantsWidgetState extends State<SelectParticipantsWidget> {
  late List<String> selectedUserIds; // เก็บข้อมูลใน State

  @override
  void initState() {
    super.initState();
    selectedUserIds = List.from(widget.selectedUserIds); // คัดลอกค่าเริ่มต้น
  }

  Future<void> _updateParticipantsInTeamSubJob() async {
    // สร้าง JSON ในรูปแบบที่ต้องการ
    final data = {
      "work_by_user_id": selectedUserIds.map((id) => id.toString()).toList(),
    };
    print(data);

    try {
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
      final url = '$apiUrl/v1/teamSubJob/${widget.teamsubJobmodel.subJobId}';

      final response = await Dio().put(
        url,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'}, // ระบุว่าเป็น JSON
        ),
      );

      if (response.statusCode == 200) {
        print('Update successful');
        print(url);
      } else {
        print('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
        print("Remove $userId");
        print(selectedUserIds);
      } else {
        selectedUserIds.add(userId);
        print("Add $userId");
        print(selectedUserIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Row(
      children: [
        Row(
          children: widget.participatingUsers.map((user) {
            final isSelected = selectedUserIds.contains(user.userId);
            return GestureDetector(
              onTap: () {
                toggleUserSelection(user.userId);
              },
              child: Container(
                width: screenWidth * 0.09,
                height: screenWidth * 0.09,
                margin: EdgeInsets.only(left: screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: isSelected ? pastel.pastelFont : pastel.pastelProgress,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '',
                    style: TextStyle(
                      color: isSelected
                          ? pastel.pastelProgress
                          : pastel.pastelFont,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () async {
            // อัปเดตข้อมูลในระบบ
            await _updateParticipantsInTeamSubJob();

            // ปิด popup
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: widget.pastel.pastelProgress,
            foregroundColor: widget.pastel.participant,
          ),
          child: Icon(Icons.add, color: widget.pastel.participant),
        ),
      ],
    );
  }
}

class AddTeamSubWorkArea extends StatefulWidget {
  final Teamsubjobmodel teamsubJobmodel;
  final Pastel pastel;

  const AddTeamSubWorkArea({
    super.key,
    required this.pastel,
    required this.teamsubJobmodel,
  });

  @override
  AddTeamSubWorkAreaState createState() => AddTeamSubWorkAreaState();
}

class AddTeamSubWorkAreaState extends State<AddTeamSubWorkArea> {
  final workLink = TextEditingController();

  Future<void> _updateParticipantsInTeamSubJob() async {
    final data = {
      "link_area_work":
          workLink.text.trim(), // สมมติว่าส่งรายชื่อทั้งหมดไปอัปเดต
    };

    try {
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
      // ใช้ `put` แทน `post` เพื่ออัปเดตข้อมูล
      final response = await Dio().put(
        '$apiUrl/v1/teamSubJob/${widget.teamsubJobmodel.subJobId}',
        data: data,
      );

      // เช็คว่าอัปเดตสำเร็จหรือไม่
      if (response.statusCode == 200) {
        print('Update successful');
        print(
            'With $apiUrl/v1/teamSubJob/${widget.teamsubJobmodel.subJobId} By $data');
      } else {
        print('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        overflow: TextOverflow.ellipsis,
        widget.teamsubJobmodel.jobId,
        style: TextStyle(
          color: widget.pastel.pastelFont,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: workLink,
            decoration: InputDecoration(
              hintText: 'Enter Work Link',
              hintStyle: TextStyle(color: widget.pastel.pastelFont),
            ),
            style: TextStyle(color: widget.pastel.pastelFont),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _updateParticipantsInTeamSubJob();
              Navigator.pop(context, true); // ปิด popup

              // หลังจากปิดหน้า dialog, สามารถรีเฟรชหน้าหลักด้วย setState
              setState(() {
                // รีเซ็ตหน้าหลักหรือโหลดข้อมูลใหม่ถ้าต้องการ
              });
            },
            child:
                const Text(overflow: TextOverflow.ellipsis, 'Change Work Link'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    workLink.dispose(); // ปิดตัวควบคุม TextController ที่ไม่ใช้
    super.dispose();
  }
}

class AddTeamSubWorkSubmit extends StatefulWidget {
  final Teamsubjobmodel teamsubJobmodel;
  final Pastel pastel;

  const AddTeamSubWorkSubmit({
    super.key,
    required this.pastel,
    required this.teamsubJobmodel,
  });

  @override
  AddTeamSubWorkSubmitState createState() => AddTeamSubWorkSubmitState();
}

class AddTeamSubWorkSubmitState extends State<AddTeamSubWorkSubmit> {
  final workLink = TextEditingController();

  Future<void> _updateParticipantsInTeamSubJob() async {
    final data = {
      "link_submit_work":
          workLink.text.trim(), // สมมติว่าส่งรายชื่อทั้งหมดไปอัปเดต
    };

    try {
      final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
      // ใช้ `put` แทน `post` เพื่ออัปเดตข้อมูล
      final response = await Dio().put(
        '$apiUrl/v1/teamSubJob/${widget.teamsubJobmodel.subJobId}',
        data: data,
      );

      // เช็คว่าอัปเดตสำเร็จหรือไม่
      if (response.statusCode == 200) {
        print('Update successful');
        print(
            'With $apiUrl/v1/teamSubJob/${widget.teamsubJobmodel.subJobId} By $data');
      } else {
        print('Update failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        overflow: TextOverflow.ellipsis,
        widget.teamsubJobmodel.jobId,
        style: TextStyle(
          color: widget.pastel.pastelFont,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: workLink,
            decoration: InputDecoration(
              hintText: 'Enter Work Link',
              hintStyle: TextStyle(color: widget.pastel.pastelFont),
            ),
            style: TextStyle(color: widget.pastel.pastelFont),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _updateParticipantsInTeamSubJob();
              Navigator.pop(context, true); // ปิด popup

              // หลังจากปิดหน้า dialog, สามารถรีเฟรชหน้าหลักด้วย setState
              setState(() {
                // รีเซ็ตหน้าหลักหรือโหลดข้อมูลใหม่ถ้าต้องการ
              });
            },
            child:
                const Text(overflow: TextOverflow.ellipsis, 'Change Work Link'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    workLink.dispose(); // ปิดตัวควบคุม TextController ที่ไม่ใช้
    super.dispose();
  }
}

Future<void> showDeleteConfirmationDialog(
    BuildContext context, String core, String jobId) async {
  print(core);
  print(jobId);
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    await deleteThis(context, core, jobId);
  }
}

Future<void> deleteThis(BuildContext context, String core, String id) async {
  try {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final url = '$apiUrl/v1/$core/$id';
    print(url);
    final response = await Dio().delete(url);

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Deletion failed with status: ${response.statusCode}')),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}

Future<void> showDeleteConfirmationAndReDialog(
    BuildContext context,
    String core,
    String jobId,
    State? stateName, // Make it nullable and typed as State
    {VoidCallback? onSubmitSuccess}) async {
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    await deleteThisAndRe(context, core, jobId, () {
      // If a state is provided, refresh it
      if (context.mounted && stateName != null) {
        stateName.setState(() {});
      }

      // Call the original onSubmitSuccess callback if provided
      onSubmitSuccess?.call();
    });
  }
}

Future<void> deleteThisAndRe(BuildContext context, String core, String id,
    Function onSubmitSuccess) async {
  try {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final url = '$apiUrl/v1/$core/$id';
    print(url);
    final response = await Dio().delete(url);

    if (response.statusCode == 200) {
      onSubmitSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Deletion failed with status: ${response.statusCode}')),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}