import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/model/theme.dart';


Future<void> createCoop({
  required String name,
  required String status,
  required String details,
  required DateTime startDate,
  required DateTime lastDate,
  required TimeOfDay startTime,
  required TimeOfDay lastTime,
  required List<String> workByUserIds,
  required String headUserId,
}) async {
  try {
    final Dio dio = Dio();
    final String url = 'http://192.168.1.36:8080/v1/teamJob'; // URL ของ API
    dio.options.headers['Content-Type'] = 'application/json';

    // การเตรียมข้อมูลที่จะแนบไปกับ API 
    final Map<String, dynamic> data = {
      'name': name,
      'status': status,
      'details': details,
      'start_date': {
        'day': startDate.day,
        'month': startDate.month,
        'year': startDate.year,
      },
      'last_date': {
        'day': lastDate.day,
        'month': lastDate.month,
        'year': lastDate.year,
      },
      'start_time': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'last_time': {
        'hour': lastTime.hour,
        'minute': lastTime.minute,
      },
      'work_by_user_id': workByUserIds,
      'head_user_id': headUserId,
    };

    // การส่งข้อมูล POST
    final response = await dio.post(url, data: data);

    if (response.statusCode == 200) {
      print('Coop created successfully');
    } else {
      print('Failed to create Coop');
    }
  } catch (e) {
    print('Error: $e');
  }
}

class CoopPage extends StatefulWidget {
  const CoopPage({Key? key}) : super(key: key);

  @override
  _CoopPageState createState() => _CoopPageState();
}

class _CoopPageState extends State<CoopPage> {
  // Variables for form values
  final TextEditingController nameController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  DateTime? startDate; // Changed to nullable
  DateTime? lastDate;  // Changed to nullable
  TimeOfDay? startTime; // Changed to nullable
  TimeOfDay? lastTime;  // Changed to nullable
  List<String> workByUserIds = ['user1', 'user2']; // Example IDs
  String headUserId = 'headUser';

  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      backgroundColor: pastel.pastel2,
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Coop',
            style: TextStyle(color: pastel.pastelFont),
          ),
        ),
      ),
      body: Center(
       
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGoalCoopBottomSheet(context, pastel);
        },
        backgroundColor: pastel.pastel1,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  void _showAddGoalCoopBottomSheet(BuildContext context, Pastel pastel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color(0xFFFFECDB), // Peach background color
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
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
                _buildTextField(controller: detailsController, label: 'Detail', maxLines: 3),
                const SizedBox(height: 20),

                // Date and Time pickers
                _buildDatePickerField(
                  label: 'Start Date',
                  onDatePicked: (DateTime date) {
                    setState(() {
                      startDate = date;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildDatePickerField(
                  label: 'End Date',
                  onDatePicked: (DateTime date) {
                    setState(() {
                      lastDate = date;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTimePickerField(
                  label: 'Start Time',
                  onTimePicked: (TimeOfDay time) {
                    setState(() {
                      startTime = time;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTimePickerField(
                  label: 'End Time',
                  onTimePicked: (TimeOfDay time) {
                    setState(() {
                      lastTime = time;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Participants section
                Row(
                  children: [
                    Expanded(child: _buildTextField(label: 'Participants')),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orange),
                      onPressed: () {
                        // Add participants functionality
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Save Button as a '+' Icon
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastel.pastel1,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      // เมื่อกดปุ่มบันทึก ส่งข้อมูลไปยัง API
                      createCoop(
                        name: nameController.text,
                        status: 'In Progress',
                        details: detailsController.text,
                        startDate: startDate!,
                        lastDate: lastDate!,
                        startTime: startTime!,
                        lastTime: lastTime!,
                        workByUserIds: workByUserIds,
                        headUserId: headUserId,
                      );
                      Navigator.pop(context); // ปิด bottom sheet
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
        );
      },
    );
  }

  // TextField Widget
  Widget _buildTextField({required String label, int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      maxLines: maxLines,
    );
  }

  // DatePicker Widget
  Widget _buildDatePickerField({required String label, required Function(DateTime) onDatePicked}) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: startDate ?? DateTime.now(),  // If no date selected, default to current date
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          onDatePicked(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          startDate != null ? '${startDate!.toLocal()}'.split(' ')[0] : 'Select date', // Show selected date or prompt
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  // TimePicker Widget
  Widget _buildTimePickerField({required String label, required Function(TimeOfDay) onTimePicked}) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: startTime ?? TimeOfDay.now(),  // If no time selected, default to current time
        );
        if (picked != null) {
          onTimePicked(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          startTime != null ? '${startTime!.format(context)}' : 'Select time', // Show selected time or prompt
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

