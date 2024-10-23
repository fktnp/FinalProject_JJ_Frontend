import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSubTaskForm {
  final BuildContext context;
  final String jobId;
  final String userId;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController frequencyDayController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String selectedFrequency = 'Day';
  Set<int> selectedWeekDays = {};
  int selectedMonthDay = 1;
  String headSubJobId = "eh";

  AddSubTaskForm({
    required this.context,
    required this.jobId,
    required this.userId,
  });

  bool isTaskNameEmpty = false;
  bool isStartDateEmpty = false;
  bool isEndDateEmpty = false;
  bool isStartTimeEmpty = false;
  bool isEndTimeEmpty = false;

  Future<void> saveSubTask() async {
    // ตรวจสอบว่า UUID และข้อมูลต่าง ๆ ถูกต้อง
    if (jobId.isEmpty ||
        userId.isEmpty ||
        taskNameController.text.isEmpty ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      return; // Handle the case where fields are empty
    }

    DateTime startDateWithTime = DateTime(
      selectedStartDate!.year,
      selectedStartDate!.month,
      selectedStartDate!.day,
      selectedStartTime?.hour ?? 8,
      selectedStartTime?.minute ?? 0,
    ).toLocal();

    DateTime endDateWithTime = DateTime(
      selectedEndDate!.year,
      selectedEndDate!.month,
      selectedEndDate!.day,
      selectedEndTime?.hour ?? 8,
      selectedEndTime?.minute ?? 0,
    ).toLocal();

    String startDateGoal = _convertToISO8601WithOffset(startDateWithTime);
    String endDateGoal = _convertToISO8601WithOffset(endDateWithTime);

    Map<String, dynamic> data = {
      "job_id": jobId,
      "user_id": userId,
      "name": taskNameController.text,
      "status": "Pending",
      "details": "",
      "start_time_goal": startDateGoal,
      "last_time_goal": endDateGoal,
      "start_date": startDateGoal,
      "last_date": endDateGoal,
      "frequency": selectedFrequency,
      "frequency_day": selectedFrequency == 'Day'
          ? int.parse(frequencyDayController.text)
          : 0,
      "frequency_week":
          selectedFrequency == 'Week' ? selectedWeekDays.join(",") : '',
      "frequency_Month": selectedFrequency == 'Month' ? selectedMonthDay : 0,
      "head_sub_job_id": "head_sub_job_id", // Ensure this has a valid value
    };

    try {
      var response = await Dio().post(
        'http://10.0.2.2:8080/v1/subjob',
        data: data,
      );
      print(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

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
                          _buildHeader(),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildTextField(
                                  'Task Name',
                                  taskNameController,
                                  isTaskNameEmpty
                                      ? 'Task Name is required'
                                      : null,
                                ),

                                // Frequency Picker
                                _buildFrequencyPicker(setState),

                                if (selectedFrequency == 'Day')
                                  _buildDailyFrequencyInput(),
                                if (selectedFrequency == 'Week')
                                  _buildWeeklyFrequencyPicker(setState),
                                if (selectedFrequency == 'Month')
                                  _buildMonthlyFrequencyPicker(setState),

                                // Date Picker for start and end date
                                _buildDatePicker(
                                    'Start Date', selectedStartDate,
                                    (pickedDate) {
                                  setState(
                                      () => selectedStartDate = pickedDate);
                                }),
                                _buildDatePicker('End Date', selectedEndDate,
                                    (pickedDate) {
                                  setState(() => selectedEndDate = pickedDate);
                                }),

                                // Time Picker for start and end time
                                _buildTimePicker(
                                    'Start Time', selectedStartTime,
                                    (pickedTime) {
                                  setState(
                                      () => selectedStartTime = pickedTime);
                                }),
                                _buildTimePicker('End Time', selectedEndTime,
                                    (pickedTime) {
                                  setState(() => selectedEndTime = pickedTime);
                                }),

                                const SizedBox(
                                  height: 30,
                                ),
                                // Save Button
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isTaskNameEmpty =
                                            taskNameController.text.isEmpty;
                                        isStartDateEmpty =
                                            selectedStartDate == null;
                                        isEndDateEmpty =
                                            selectedEndDate == null;
                                        isStartTimeEmpty =
                                            selectedStartDate == null;
                                        isEndTimeEmpty =
                                            selectedEndDate == null;
                                      });
                                      if (!isTaskNameEmpty &&
                                          !isStartDateEmpty &&
                                          !isEndDateEmpty &&
                                          !isStartTimeEmpty &&
                                          !isEndTimeEmpty) {
                                        saveSubTask();
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 30,
                                    )),
                              ],
                            ),
                          ),
                          // Task Name Input
                        ],
                      ),
                    )));
          },
        );
      },
    );
  }

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
          'Add Sub Goal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String? errorText,
  ) {
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

  Widget _buildFrequencyPicker(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: DropdownButton<String>(
        value: selectedFrequency,
        items: ['Day', 'Week', 'Month'].map((String frequency) {
          return DropdownMenuItem<String>(
            value: frequency,
            child: Text(frequency),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedFrequency = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildDailyFrequencyInput() {
    return Padding(
      padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.35,
          left: MediaQuery.of(context).size.width * 0.35),
      child: TextField(
        controller: frequencyDayController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildWeeklyFrequencyPicker(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 20),
      child: Column(
        children: List.generate(7, (index) {
          return CheckboxListTile(
            title: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.35,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text([
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday'
              ][index]),
            ),
            value: selectedWeekDays.contains(index),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  selectedWeekDays.add(index);
                } else {
                  selectedWeekDays.remove(index);
                }
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyFrequencyPicker(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: DropdownButton<int>(
        value: selectedMonthDay,
        items: List.generate(31, (index) {
          return DropdownMenuItem<int>(
            value: index + 1,
            child: Text('Day ${index + 1}'),
          );
        }),
        onChanged: (int? newValue) {
          setState(() {
            selectedMonthDay = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      ValueChanged<DateTime> onDatePicked) {
    return Container(
      margin: EdgeInsets.only(
          top: 8, left: 8, right: MediaQuery.of(context).size.width * 0.45),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        children: [
          Text(label),
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
                : selectedDate.toLocal().toString().split(' ')[0]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? selectedTime,
      ValueChanged<TimeOfDay> onTimePicked) {
    return Container(
      margin: EdgeInsets.only(
          top: 8, left: 8, right: MediaQuery.of(context).size.width * 0.45),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(123, 36, 36, 36), width: 1.5)),
      child: Row(
        children: [
          Text(label),
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
