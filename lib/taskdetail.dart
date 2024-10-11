import 'package:flutter/material.dart';
import 'task.dart'; // ตรวจสอบว่ามีการนำเข้า Task class ที่นี่

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCBC),
        title: Align(
          alignment: Alignment.centerRight,
          child: const Text(
            'Goal',
            style: TextStyle(color: Colors.black),
          ),
        ),
        automaticallyImplyLeading: false, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.taskName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              task.taskDate.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${task.taskStartHour.toString().padLeft(2, '0')}:00 - ${task.taskEndHour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // เพิ่มรายละเอียดอื่นๆได้ด้านล่างนี้นะ
          ],
        ),
      ),
    );
  }
}
