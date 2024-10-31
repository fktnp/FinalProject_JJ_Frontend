import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/theme.dart';

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
  String selectedFrequency = 'daily';
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
    if (jobId.isEmpty ||
        userId.isEmpty ||
        taskNameController.text.isEmpty ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      return; // Handle the case where fields are empty
    }

    Map<String, dynamic> data = {
      "job_id": jobId,
      "user_id": userId,
      "name": taskNameController.text,
      "status": "Pending",
      "details": "",
      "start_time_goal": {
        "hour": selectedStartTime?.hour ?? 8,
        "minute": selectedStartTime?.minute ?? 0,
      },
      "last_time_goal": {
        "hour": selectedEndTime?.hour ?? 8,
        "minute": selectedEndTime?.minute ?? 0,
      },
      "start_date": {
        "day": selectedStartDate!.day,
        "month": selectedStartDate!.month,
        "year": selectedStartDate!.year,
      },
      "last_date": {
        "day": selectedEndDate!.day,
        "month": selectedEndDate!.month,
        "year": selectedEndDate!.year,
      },
      "frequency": selectedFrequency,
      "frequency_day": selectedFrequency == 'daily'
          ? int.parse(frequencyDayController.text)
          : 0,
      "frequency_week": selectedFrequency == 'weekly'
          ? selectedWeekDays
              .map((index) => [
                    'Sunday',
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday'
                  ][index])
              .toList()
          : [],
      "frequency_Month":
          selectedFrequency == 'monthly' ? [selectedMonthDay] : [],
      "head_sub_job_id": "headSub123", // Ensure this has a valid value
    };

    try {
      var response = await Dio().post(
        'http://192.168.1.35:8080/v1/subjob',
        data: data,
      );
      print(response.data);
      print(data);
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  void show() {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
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
                  decoration: BoxDecoration(
                    color: pastel.pastel2,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, 
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, 
                          children: [
                            _buildTextField(
                              'Task Name',
                              taskNameController,
                              isTaskNameEmpty ? 'Task Name is required' : null,
                            ),
                            _buildFrequencyPicker(setState),
                            if (selectedFrequency == 'daily')
                              _buildDailyFrequencyInput(),
                            if (selectedFrequency == 'weekly')
                              _buildWeeklyFrequencyPicker(setState),
                            if (selectedFrequency == 'monthly')
                              _buildMonthlyFrequencyPicker(setState),
                            _buildDatePicker('Start Date', selectedStartDate,
                                (pickedDate) {
                              setState(() => selectedStartDate = pickedDate);
                            }),
                            _buildDatePicker('End Date', selectedEndDate,
                                (pickedDate) {
                              setState(() => selectedEndDate = pickedDate);
                            }),
                            _buildTimePicker('Start Time', selectedStartTime,
                                (pickedTime) {
                              setState(() => selectedStartTime = pickedTime);
                            }),
                            _buildTimePicker('End Time', selectedEndTime,
                                (pickedTime) {
                              setState(() => selectedEndTime = pickedTime);
                            }),
                            const SizedBox(height: 10),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isTaskNameEmpty =
                                        taskNameController.text.isEmpty;
                                    isStartDateEmpty =
                                        selectedStartDate == null;
                                    isEndDateEmpty = selectedEndDate == null;
                                    isStartTimeEmpty =
                                        selectedStartTime == null;
                                    isEndTimeEmpty = selectedEndTime == null;
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
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 220, 188),
                                  padding: EdgeInsets.all(10),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 40,
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
          'Add Sub Goal',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: pastel.pastelFont),
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
            color: const Color.fromARGB(123, 36, 36, 36), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        // ลบเส้นขีดล่าง
        child: Row(
          mainAxisSize: MainAxisSize.min, // ขนาดของ Row เท่ากับเนื้อหาภายใน
          children: [
            DropdownButton<String>(
              value: selectedFrequency,
              items: ['daily', 'weekly', 'monthly'].map((String frequency) {
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
              isExpanded: false, // ไม่ขยายให้เต็มความกว้าง
              icon: const Icon(Icons.arrow_drop_down,
                  color: Colors.black), // ไอคอน dropdown
              dropdownColor: Colors.white, // สีพื้นหลังของ dropdown
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFrequencyInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 60, // กำหนดความกว้าง
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
      ),
    );
  }

  Widget _buildWeeklyFrequencyPicker(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10),
      child: GridView.count(
        crossAxisCount: 4, // เพิ่มเป็น 4 คอลัมน์
        shrinkWrap: true, // ย่อขนาดให้พอดีกับเนื้อหา
        physics: NeverScrollableScrollPhysics(), // ปิดการเลื่อน
        children: List.generate(7, (index) {
          String day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index];
          return Card(
            elevation: 1, // เพิ่มเงาให้การ์ด
            margin: EdgeInsets.all(8), // เพิ่มระยะห่างรอบการ์ด
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // มุมมน
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (selectedWeekDays.contains(index)) {
                    selectedWeekDays.remove(index);
                  } else {
                    selectedWeekDays.add(index);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedWeekDays.contains(index)
                      ? const Color.fromARGB(255, 255, 220, 188)
                      : Colors.white, // เปลี่ยนสีพื้นหลังเมื่อเลือก
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 35, 32, 32)
                        .withOpacity(0.5), // เส้นขอบ
                  ),
                ),
                child: Center(
                  child: Text(
                    day,
                    maxLines: 1, // จำกัดให้แสดงได้ 1 บรรทัด
                    overflow: TextOverflow
                        .ellipsis, // ใช้ '...' เมื่อข้อความยาวเกินไป
                    style: TextStyle(
                      color: selectedWeekDays.contains(index)
                          ? Colors.white
                          : Colors.black, // เปลี่ยนสีข้อความตามสถานะ
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

Widget _buildMonthlyFrequencyPicker(StateSetter setState) {
  return Container(
    margin: const EdgeInsets.all(4.0),
    padding: const EdgeInsets.symmetric(horizontal: 5),
    constraints: BoxConstraints(maxWidth: 100), // กำหนดความกว้างสูงสุด
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: const Color.fromARGB(123, 36, 36, 36), width: 1.5),
    ),
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
      isExpanded: true, // ให้ Dropdown ขยายเต็มพื้นที่
    ),
  );
}


  Widget _buildDatePicker(String label, DateTime? selectedDate,
      ValueChanged<DateTime> onDatePicked) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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

  Widget _buildTimePicker(String label, TimeOfDay? selectedTime,
      ValueChanged<TimeOfDay> onTimePicked) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
