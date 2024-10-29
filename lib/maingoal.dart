import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddFromGoal {
  final BuildContext context;
  final String goal;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  AddFromGoal({required this.context, required this.goal});

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  bool isTaskNameEmpty = false;
  bool isStartDateEmpty = false;
  bool isEndDateEmpty = false;

  Future<void> saveTask() async {
    // Validate input fields
    if (taskNameController.text.isEmpty ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      return; // Handle the case where fields are empty
    }

    // Gather the necessary information
    String userId =
        "59ae0cbd-c715-4f1a-92cc-f9f192dc2837"; // Replace with actual user ID
    String taskName =
        taskNameController.text; // Get task name from the input field
    String status = "Pending"; // Default status
    String category = goal; // Use goal as category
    String details = detailController.text; // Get details from the input field

    // ตั้งค่าเวลาเป็น 08:00:00 และแปลงให้เป็น ISO 8601 พร้อม timezone
    DateTime startDateWithTime = DateTime(
      selectedStartDate!.year,
      selectedStartDate!.month,
      selectedStartDate!.day,
      8,
      0,
      0,
    ).toLocal(); // แปลงวันที่เป็นเวลา 08:00:00 และใช้ local timezone

    DateTime endDateWithTime = DateTime(
      selectedEndDate!.year,
      selectedEndDate!.month,
      selectedEndDate!.day,
      8,
      0,
      0,
    ).toLocal(); // แปลงวันที่สิ้นสุดเป็นเวลา 08:00:00

    // Convert to ISO 8601 format with timezone offset +07:00
    String startDateGoal = _convertToISO8601WithOffset(startDateWithTime);
    String endDateGoal = _convertToISO8601WithOffset(endDateWithTime);

    // Prepare the data map for the API request
    Map<String, dynamic> data = {
      "user_id": userId,
      "name": taskName,
      "status": status,
      "category": category,
      "details": details,
      "start_time_goal": startDateGoal,
      "last_time_goal": endDateGoal,
    };

    // Make the API call to save the task
    try {
      var response = await Dio().post(
        'http://192.168.1.35:8080/v1/job',
        data: data,
      );
      print(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  // ฟังก์ชันแปลงวันที่เป็น ISO 8601 พร้อม timezone offset +07:00
  String _convertToISO8601WithOffset(DateTime date) {
    final String formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
    return "$formattedDate+07:00";
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

                            // Start Date Picker
                            _buildDatePicker(
                              context: context,
                              date: selectedStartDate,
                              isError: isStartDateEmpty,
                              setState: setState,
                              label: 'Start Date',
                              onDatePicked: (pickedDate) {
                                setState(() {
                                  selectedStartDate = pickedDate;
                                  isStartDateEmpty = false;
                                });
                              },
                            ),

                            // End Date Picker
                            _buildDatePicker(
                              context: context,
                              date: selectedEndDate,
                              isError: isEndDateEmpty,
                              setState: setState,
                              label: 'End Date',
                              onDatePicked: (pickedDate) {
                                setState(() {
                                  selectedEndDate = pickedDate;
                                  isEndDateEmpty = false;
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
                                    isStartDateEmpty =
                                        selectedStartDate == null;
                                    isEndDateEmpty = selectedEndDate == null;
                                  });

                                  if (!isTaskNameEmpty &&
                                      !isStartDateEmpty &&
                                      !isEndDateEmpty) {
                                    saveTask();
                                    Navigator.pop(context);
                                  }
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
  Widget _buildDatePicker({
    required BuildContext context,
    required DateTime? date,
    required bool isError,
    required StateSetter setState,
    required String label,
    required Function(DateTime) onDatePicked,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        date == null ? 'Select $label' : DateFormat.yMMMd().format(date),
        style: TextStyle(
          color: isError ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      leading: Icon(
        Icons.calendar_today,
        color: isError ? Colors.red : Colors.black,
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onDatePicked(pickedDate);
        }
      },
    );
  }
}