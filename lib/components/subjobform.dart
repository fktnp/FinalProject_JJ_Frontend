import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../model/theme.dart';
import 'package:http/http.dart' as http;

class AddSubTaskForm {
  final BuildContext context;
  final String jobId;
  final String userId;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController frequencyDayController = TextEditingController();
  final Function onSubmitSuccess;
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
    required this.onSubmitSuccess,
  });

  bool isTaskNameEmpty = false;
  bool isStartDateEmpty = false;
  bool isEndDateEmpty = false;
  bool isStartTimeEmpty = false;
  bool isEndTimeEmpty = false;

  Future<void> saveSubTask() async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    if (jobId.isEmpty ||
        userId.isEmpty ||
        taskNameController.text.isEmpty ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      // _triggerServerCreation();
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
      await Dio().post(
        '$apiUrl/v1/subjob',
        data: data,
      );
      onSubmitSuccess();
      print('sent complete');
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error status code: ${e.response?.statusCode}');
        print('Error saving task: ${e.response?.data}');
      } else {
        print('Error sending request: ${e.message}');
      }
    }
  }

  Future<void> _triggerServerCreation() async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final url = '$apiUrl/v1/calendar/subjob/user/$userId';

    try {
      final response =
          await http.get(Uri.parse(url)); // ใช้ GET ตามที่ตั้งค่าใน Postman
      if (response.statusCode == 200) {
        print(
            'Server triggered successfully $apiUrl/v1/calendar/subjob/user/$userId');
      } else {
        print('Failed to trigger server: ${response.statusCode}');
      }
    } catch (error) {
      print('Error triggering server: $error');
    }
  }

  void show() {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    final mediaQuery = MediaQuery.of(context);
    // final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            AppLocalizations.of(context).translate('task_name'),
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
                          _buildDatePicker(
                              AppLocalizations.of(context)
                                  .translate('start')
                                  .replaceFirst(
                                      '{text}',
                                      AppLocalizations.of(context)
                                          .translate('day')),
                              selectedStartDate, (pickedDate) {
                            setState(() => selectedStartDate = pickedDate);
                          }),
                          _buildDatePicker(
                              AppLocalizations.of(context)
                                  .translate('end')
                                  .replaceFirst(
                                      '{text}',
                                      AppLocalizations.of(context)
                                          .translate('day')),
                              selectedEndDate, (pickedDate) {
                            setState(() => selectedEndDate = pickedDate);
                          }),
                          _buildTimePicker(
                              AppLocalizations.of(context)
                                  .translate('start')
                                  .replaceFirst(
                                      '{text}',
                                      AppLocalizations.of(context)
                                          .translate('time')),
                              selectedStartTime, (pickedTime) {
                            setState(() => selectedStartTime = pickedTime);
                          }),
                          _buildTimePicker(
                              AppLocalizations.of(context)
                                  .translate('end')
                                  .replaceFirst(
                                      '{text}',
                                      AppLocalizations.of(context)
                                          .translate('time')),
                              selectedEndTime, (pickedTime) {
                            setState(() => selectedEndTime = pickedTime);
                          }),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isTaskNameEmpty =
                                      taskNameController.text.isEmpty;
                                  isStartDateEmpty = selectedStartDate == null;
                                  isEndDateEmpty = selectedEndDate == null;
                                  isStartTimeEmpty = selectedStartTime == null;
                                  isEndTimeEmpty = selectedEndTime == null;
                                });
                                if (!isTaskNameEmpty &&
                                    !isStartDateEmpty &&
                                    !isEndDateEmpty &&
                                    !isStartTimeEmpty &&
                                    !isEndTimeEmpty) {
                                  Navigator.pop(context);
                                  await saveSubTask();
                                  await _triggerServerCreation();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: pastel.pastel1,
                                padding: const EdgeInsets.all(10),
                              ),
                              child: Icon(
                                Icons.add,
                                color: pastel.pastelFont,
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
            ));
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
          overflow: TextOverflow.ellipsis,
          AppLocalizations.of(context).translate('add_goal').replaceFirst(
              '{text}', AppLocalizations.of(context).translate('sub')),
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return TextField(
      style: TextStyle(color: pastel.pastelFont),
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: pastel.pastelFont),
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: pastel.pastel1,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFrequencyPicker(StateSetter setState) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: pastel.pastel1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        // ลบเส้นขีดล่าง
        child: Row(
          mainAxisSize: MainAxisSize.min, // ขนาดของ Row เท่ากับเนื้อหาภายใน
          children: [
            DropdownButton<String>(
              style: TextStyle(color: pastel.pastelFont),
              value: selectedFrequency,
              items: ['daily', 'weekly', 'monthly'].map((String frequency) {
                String frequencyTranslation;
                switch (frequency) {
                  case 'daily':
                    frequencyTranslation =
                        AppLocalizations.of(context).translate('daily');
                    break;
                  case 'weekly':
                    frequencyTranslation =
                        AppLocalizations.of(context).translate('weekly');
                    break;
                  case 'monthly':
                    frequencyTranslation =
                        AppLocalizations.of(context).translate('monthly');
                    break;
                  default:
                    frequencyTranslation = frequency;
                }
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(
                      overflow: TextOverflow.ellipsis, frequencyTranslation),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFrequency = newValue!;
                });
              },
              isExpanded: false, // ไม่ขยายให้เต็มความกว้าง
              icon: Icon(Icons.arrow_drop_down,
                  color: pastel.pastelFont), // ไอคอน dropdown
              dropdownColor: pastel.pastel2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFrequencyInput() {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        width: 60, // กำหนดความกว้าง
        child: TextField(
          style: TextStyle(color: pastel.pastelFont),
          controller: frequencyDayController,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: pastel.pastelFont),
            filled: true,
            fillColor: pastel.pastel1,
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 0),
      child: GridView.count(
        crossAxisCount: 4, // เพิ่มเป็น 4 คอลัมน์
        shrinkWrap: true, // ย่อขนาดให้พอดีกับเนื้อหา
        physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อน
        children: List.generate(7, (index) {
          String dayTrans = [
            AppLocalizations.of(context).translate('sun'),
            AppLocalizations.of(context).translate('mon'),
            AppLocalizations.of(context).translate('tue'),
            AppLocalizations.of(context).translate('wed'),
            AppLocalizations.of(context).translate('thu'),
            AppLocalizations.of(context).translate('fri'),
            AppLocalizations.of(context).translate('sat')
          ][index];
          return Card(
            elevation: 1, // เพิ่มเงาให้การ์ด
            margin: const EdgeInsets.all(8), // เพิ่มระยะห่างรอบการ์ด
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedWeekDays.contains(index)
                      ? pastel.pastelFont
                      : pastel.pastel1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    dayTrans,
                    maxLines: 1, // จำกัดให้แสดงได้ 1 บรรทัด

                    style: TextStyle(
                      color: selectedWeekDays.contains(index)
                          ? pastel.pastel1
                          : pastel.pastelFont, // เปลี่ยนสีข้อความตามสถานะ
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      constraints: const BoxConstraints(maxWidth: 100), // กำหนดความกว้างสูงสุด
      decoration: BoxDecoration(
        color: pastel.pastel1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color.fromARGB(123, 36, 36, 36), width: 1.5),
      ),
      child: DropdownButton<int>(
        value: selectedMonthDay,
        items: List.generate(31, (index) {
          return DropdownMenuItem<int>(
            value: index + 1,
            child: Text(
              overflow: TextOverflow.ellipsis,
              '${AppLocalizations.of(context).translate('date')} ${index + 1}',
              style: TextStyle(color: pastel.pastelFont),
            ),
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildTimePicker(String label, TimeOfDay? selectedTime,
      ValueChanged<TimeOfDay> onTimePicked) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
