import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/theme.dart';

class CoopPage extends StatelessWidget {
  const CoopPage({Key? key}) : super(key: key);

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
        child: Text(
          "เนื้อหาของ CoopPage",
          style: TextStyle(
            color: pastel.pastelFont,
            fontSize: 18,
          ),
        ),
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
              _buildTextField(label: 'ชื่อหัวข้อ'),
              const SizedBox(height: 20),
              _buildTextField(label: 'รายละเอียด', maxLines: 3),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDropdownField(label: 'เริ่ม')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdownField(label: 'ถึง')),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'ผู้เข้าร่วม')),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.orange),
                    onPressed: () {
                      // การดำเนินการเพิ่มผู้เข้าร่วม
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
                    // การดำเนินการบันทึกข้อมูล
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
Widget _buildTextField({required String label, int maxLines = 1}) {
  return TextField(
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

// Dropdown Field Widget (Example implementation)
Widget _buildDropdownField({required String label}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    items: ['Option 1', 'Option 2', 'Option 3'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (String? newValue) {
      // Handle dropdown selection
    },
  );
}


  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget _buildTextField({int maxLines = 1}) {
  //   return TextFormField(
  //     maxLines: maxLines,
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.grey[200],
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //         borderSide: BorderSide.none,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDropdownField(String label) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 16),
  //       ),
  //       const SizedBox(height: 6),
  //       DropdownButtonFormField(
  //         items: ['ตัวเลือก1', 'ตัวเลือก2']
  //             .map((String value) => DropdownMenuItem(
  //                   value: value,
  //                   child: Text(value),
  //                 ))
  //             .toList(),
  //         onChanged: (value) {},
  //         decoration: InputDecoration(
  //           filled: true,
  //           fillColor: Colors.grey[200],
  //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //             borderSide: BorderSide.none,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
