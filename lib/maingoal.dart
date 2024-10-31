import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/theme.dart';

class AddFromGoal {
  final BuildContext context;
  final String loginuserid;
  final String goal;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  AddFromGoal({required this.context, required this.goal,required this.loginuserid});

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
    String userId = loginuserid;
    String taskName =
        taskNameController.text; // Get task name from the input field
    String status = "Pending"; // Default status
    String category = goal; // Use goal as category
    String details = detailController.text; // Get details from the input field

    // Prepare the data map for the API request
    Map<String, dynamic> data = {
      "user_id": userId,
      "name": taskName,
      "status": status,
      "category": category,
      "details": details,
      "start_time_goal": {
        "day": selectedStartDate!.day,
        "month": selectedStartDate!.month,
        "year": selectedStartDate!.year,
      },
      "last_time_goal": {
        "day": selectedEndDate!.day,
        "month": selectedEndDate!.month,
        "year": selectedEndDate!.year,
      },
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

  void show() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final Pastel pastel = Theme.of(context).extension<Pastel>()!;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: pastel.pastel2,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      // Text(loginuserid),
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
                                  backgroundColor: pastel.pastel1,
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
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
          'Add Main Goal',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: pastel.pastelFont),
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