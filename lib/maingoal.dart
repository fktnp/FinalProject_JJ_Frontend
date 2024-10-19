import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddFromGoal {
  final BuildContext context;
  final String goal;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  AddFromGoal({required this.context, required this.goal});

  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  DateTime? selectedDate;

  bool isTaskNameEmpty = false;
  bool isDateEmpty = false;
  bool isStartTimeEmpty = false;
  bool isEndTimeEmpty = false;

  // Commenting out Dio usage until you are ready to use it
  final Dio dio = Dio();

  Future<void> saveTask() async {
  // Validate input fields
  if (taskNameController.text.isEmpty || selectedDate == null || selectedStartTime == null || selectedEndTime == null) {
    // Handle the case where fields are empty, e.g., showing an error message
    return;
  }

  // Gather the necessary information
  String userId = "59ae0cbd-c715-4f1a-92cc-f9f192dc2837"; // Replace with actual user ID
  String taskName = taskNameController.text; // Get task name from the input field
  String status = "Pending"; // Default status or modify as needed
  String category = "Development"; // Change as necessary
  String details = detailController.text; // Get details from the input field

  // Format date and times
  DateTime startDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedStartTime!.hour,
    selectedStartTime!.minute,
  );

  DateTime endDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedEndTime!.hour,
    selectedEndTime!.minute,
  );

  // Convert to ISO 8601 format
  String startTimeGoal = startDateTime.toIso8601String(); // Format to ISO 8601
  String lastTimeGoal = endDateTime.toIso8601String(); // Format to ISO 8601

  // Prepare the data map for the API request
  Map<String, dynamic> data = {
    "user_id": userId,
    "name": taskName,
    "status": status,
    "category": category,
    "details": details,
    "start_time_goal": startTimeGoal,
    "last_time_goal": lastTimeGoal,
  };

  // Make the API call to save the task
  try 
  { dio.options.headers['Content-Type'] = 'application/json'; // ตั้งค่า Header สำหรับ JSON
    Response response = await dio.post(
      'http://10.250.105.93:8080/v1/job', // Replace with the actual API endpoint
      data: data,
    );

    if (response.statusCode == 200) {
      // Successfully saved the task
      Navigator.pop(context);
    } else {
      print('Failed to save task: ${response.statusCode}');
    }
  } catch (e) {
    print('Error saving task: $e');
  }
}


  void show() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECDB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Name Input
                            _buildTextField(
                              label: 'Task Name',
                              controller: taskNameController,
                              errorText: isTaskNameEmpty
                                  ? 'Task Name is required'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Detail Input
                            _buildTextField(
                              label: 'Detail',
                              controller: detailController,
                              errorText: null,
                            ),
                            const SizedBox(height: 20),

                            // Date Picker
                            _buildDatePicker(context, setState),
                            const SizedBox(height: 10),

                            // Start Time Picker
                            _buildTimePicker(
                              context: context,
                              time: selectedStartTime,
                              isError: isStartTimeEmpty,
                              setState: setState,
                              label: 'Start Time',
                              onTimePicked: (time) {
                                setState(() {
                                  selectedStartTime = time;
                                  isStartTimeEmpty = false;
                                });
                              },
                            ),


                            // End Time Picker
                            _buildTimePicker(
                              context: context,
                              time: selectedEndTime,
                              isError: isEndTimeEmpty,
                              setState: setState,
                              label: 'End Time',
                              onTimePicked: (time) {
                                setState(() {
                                  selectedEndTime = time;
                                  isEndTimeEmpty = false;
                                });
                              },
                            ),

                            const SizedBox(height: 20),
                            // Save Task Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFDCBC),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isTaskNameEmpty =
                                        taskNameController.text.isEmpty;
                                    isDateEmpty = selectedDate == null;
                                    isStartTimeEmpty =
                                        selectedStartTime == null;
                                    isEndTimeEmpty = selectedEndTime == null;
                                  });

                                  if (!isTaskNameEmpty &&
                                      !isDateEmpty &&
                                      !isStartTimeEmpty &&
                                      !isEndTimeEmpty) {
                                    saveTask(); // เปิดใช้งานเมื่อพร้อมบันทึก
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black, // กำหนดสีไอคอนเป็นสีดำ
                                  size: 30, // กำหนดขนาดไอคอน
                                ),
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
          },
        );
      },
    );
  }

// Header Widget
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Color(0xFFFFDCBC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Center(
        child: Text(
          'Add Main Goal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

// TextField Widget
 Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  String? errorText,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onChanged: (value) {
      // Handle changes here, if necessary
    },
  );
}



// Date Picker Widget
  Widget _buildDatePicker(BuildContext context, StateSetter setState) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        selectedDate == null
            ? 'Select Date'
            : DateFormat.yMMMd().format(selectedDate!),
        style: TextStyle(
          color: isDateEmpty ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      leading: Icon(
        Icons.calendar_today,
        color: isDateEmpty ? Colors.red : Colors.black,
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
            isDateEmpty = false;
          });
        }
      },
    );
  }

// Time Picker Widget
  Widget _buildTimePicker({
    required BuildContext context, // ใช้ BuildContext ที่ถูกต้อง
    required TimeOfDay? time,
    required bool isError,
    required StateSetter setState,
    required String label, // เปลี่ยนจาก context เป็น label
    required Function(TimeOfDay) onTimePicked,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        time == null ? 'Select $label' : time.format(context), // ใช้ label แทน
        style: TextStyle(
          color: isError ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      leading: Icon(
        Icons.access_time,
        color: isError ? Colors.red : Colors.black,
      ),
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onTimePicked(pickedTime);
        }
      },
    );
  }
}