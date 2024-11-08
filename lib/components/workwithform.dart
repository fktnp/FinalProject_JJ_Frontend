import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/teamjobmodel.dart';
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
      // ใช้ `put` แทน `post` เพื่ออัปเดตข้อมูล
      final response = await Dio().put(
        'http://10.0.2.2:8080/v1/teamJob/${widget.teamjobmodel.jobId}',
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
      Navigator.of(context).pop(); // ปิด popup

      // หลังจากปิดหน้า dialog, สามารถรีเฟรชหน้าหลักด้วย setState
      setState(() {
        // รีเซ็ตหน้าหลักหรือโหลดข้อมูลใหม่ถ้าต้องการ
      });
    }
  }

  // void _addParticipant() async {
  //   final email = _emailController.text.trim();
  //   if (email.isNotEmpty && !widget.currentParticipants.contains(email)) {
  //     User? newUser = await fetchUserByEmail(email);
  //     if (newUser != null) {
  //       onParticipantAdded(newUser.userId);
  //       _emailController.clear();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'No user found with email: $email',
  //             style: TextStyle(color: widget.pastel.pastelFont),
  //           ),
  //           backgroundColor: widget.pastel.pastelBlock,
  //         ),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Please enter a valid email and make sure the user is not already added.',
  //           style: TextStyle(color: widget.pastel.pastelFont),
  //         ),
  //         backgroundColor: widget.pastel.pastelBlock,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
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
                final User? newUser = await fetchUserByEmail(email);
                if (newUser != null) {
                  onParticipantAdded(newUser.userId);
                }
              }
            },
            child: const Text('Add Participant'),
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
