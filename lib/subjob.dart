// import 'package:flutter/material.dart';

// class GoaladdPage extends StatefulWidget {
//   const GoaladdPage({super.key});
//   @override
//   _GoalSettingPageState createState() => _GoalSettingPageState();
// }

// class _GoalSettingPageState extends State<GoaladdPage> {
//   // Variables for storing user input
//   String? goalName;
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   String? frequency;
//   DateTime? endDate;
//   int? dayInterval; // for daily frequency
//   int? weekInterval; // for weekly frequency
//   List<String> selectedDaysOfWeek = []; // for days of the week
//   int? monthInterval; // for monthly frequency
//   int? selectedDayOfMonth; // for monthly date
//   String? selectedMonth; // for yearly frequency
//   int? yearInterval; // for yearly frequency

//   // List of frequencies
//   List<String> frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
//   List<String> daysOfWeek = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday'
//   ];
//   List<String> monthsOfYear = [
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December'
//   ];

//   // Function to pick start time
//   Future<void> _pickStartTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != startTime) {
//       setState(() {
//         startTime = picked;
//       });
//     }
//   }

//   // Function to pick end time
//   Future<void> _pickEndTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != endTime) {
//       setState(() {
//         endTime = picked;
//       });
//     }
//   }

//   // Function to pick end date using Flutter's showDatePicker
//   Future<void> _pickEndDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != endDate) {
//       setState(() {
//         endDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFECDB), // สีพื้นหลัง
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFDCBC), // สีหัวข้อ
//         title: const Text('Add Goal'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             // Goal Name Input
//             TextField(
//               decoration: const InputDecoration(labelText: 'Goal Name'),
//               onChanged: (value) {
//                 setState(() {
//                   goalName = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 16.0),

//             // Time Picker for Start Time
//             ListTile(
//               title: Text(startTime != null
//                   ? "Start Time: ${startTime!.format(context)}"
//                   : "Pick Start Time"),
//               trailing: const Icon(Icons.access_time),
//               onTap: () => _pickStartTime(context),
//             ),

//             // Time Picker for End Time
//             ListTile(
//               title: Text(endTime != null
//                   ? "End Time: ${endTime!.format(context)}"
//                   : "Pick End Time"),
//               trailing: const Icon(Icons.access_time),
//               onTap: () => _pickEndTime(context),
//             ),

//             // Frequency Dropdown
//             DropdownButton<String>(
//               hint: const Text('Select Frequency'),
//               value: frequency,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   frequency = newValue;
//                   dayInterval = null;
//                   weekInterval = null;
//                   selectedDaysOfWeek.clear();
//                   monthInterval = null;
//                   selectedDayOfMonth = null;
//                   selectedMonth = null;
//                   yearInterval = null;
//                 });
//               },
//               items: frequencies.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 16.0),

//             // Frequency Specific Options
//             if (frequency == 'Daily')
//               Column(
//                 children: [
//                   const Text('Repeat every'),
//                   DropdownButton<int>(
//                     value: dayInterval,
//                     hint: const Text('Day(s)'),
//                     onChanged: (int? value) {
//                       setState(() {
//                         dayInterval = value;
//                       });
//                     },
//                     items: List.generate(7, (index) => index + 1)
//                         .map((int value) => DropdownMenuItem<int>(
//                               value: value,
//                               child: Text('$value Day(s)'),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//             if (frequency == 'Weekly')
//               Column(
//                 children: [
//                   const Text('Repeat every'),
//                   DropdownButton<int>(
//                     value: weekInterval,
//                     hint: const Text('Week(s)'),
//                     onChanged: (int? value) {
//                       setState(() {
//                         weekInterval = value;
//                       });
//                     },
//                     items: List.generate(4, (index) => index + 1)
//                         .map((int value) => DropdownMenuItem<int>(
//                               value: value,
//                               child: Text('$value Week(s)'),
//                             ))
//                         .toList(),
//                   ),
//                   const Text('On these days'),
//                   Wrap(
//                     spacing: 8.0,
//                     children: daysOfWeek.map((day) {
//                       return FilterChip(
//                         label: Text(day),
//                         selected: selectedDaysOfWeek.contains(day),
//                         onSelected: (bool selected) {
//                           setState(() {
//                             if (selected) {
//                               selectedDaysOfWeek.add(day);
//                             } else {
//                               selectedDaysOfWeek.remove(day);
//                             }
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             if (frequency == 'Monthly')
//               Column(
//                 children: [
//                   const Text('Repeat every'),
//                   DropdownButton<int>(
//                     value: monthInterval,
//                     hint: const Text('Month(s)'),
//                     onChanged: (int? value) {
//                       setState(() {
//                         monthInterval = value;
//                       });
//                     },
//                     items: List.generate(12, (index) => index + 1)
//                         .map((int value) => DropdownMenuItem<int>(
//                               value: value,
//                               child: Text('$value Month(s)'),
//                             ))
//                         .toList(),
//                   ),
//                   const Text('On day'),
//                   DropdownButton<int>(
//                     value: selectedDayOfMonth,
//                     hint: const Text('Day of Month'),
//                     onChanged: (int? value) {
//                       setState(() {
//                         selectedDayOfMonth = value;
//                       });
//                     },
//                     items: List.generate(31, (index) => index + 1)
//                         .map((int value) => DropdownMenuItem<int>(
//                               value: value,
//                               child: Text('Day $value'),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//             if (frequency == 'Yearly')
//               Column(
//                 children: [
//                   const Text('Repeat every'),
//                   DropdownButton<int>(
//                     value: yearInterval,
//                     hint: const Text('Year(s)'),
//                     onChanged: (int? value) {
//                       setState(() {
//                         yearInterval = value;
//                       });
//                     },
//                     items: List.generate(10, (index) => index + 1)
//                         .map((int value) => DropdownMenuItem<int>(
//                               value: value,
//                               child: Text('$value Year(s)'),
//                             ))
//                         .toList(),
//                   ),
//                   const Text('In month'),
//                   DropdownButton<String>(
//                     value: selectedMonth,
//                     hint: const Text('Month'),
//                     onChanged: (String? value) {
//                       setState(() {
//                         selectedMonth = value;
//                       });
//                     },
//                     items: monthsOfYear
//                         .map((String value) => DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),

//             ListTile(
//               title: Text(endDate != null
//                   ? "End Date: ${endDate!.toLocal()}".split(' ')[0]
//                   : "Pick End Date"),
//               trailing: const Icon(Icons.calendar_today),
//               onTap: () => _pickEndDate(context),
//             ),

//             // Submit Button
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFFECDB),
//                   shape: const CircleBorder(),
//                   padding: const EdgeInsets.all(20),
//                 ),
//                 onPressed: () {
//                   if (goalName == null || goalName!.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter a goal name')),
//                     );
//                     return;
//                   }

//                   if (startTime == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please pick a start time')),
//                     );
//                     return;
//                   }

//                   if (endTime == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please pick an end time')),
//                     );
//                     return;
//                   }

//                   if (frequency == null || frequency!.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Please select a frequency')),
//                     );
//                     return;
//                   }

//                   // Handle the submission logic here
//                   print('Goal Name: $goalName');
//                   print('Start Time: ${startTime?.format(context)}');
//                   print('End Time: ${endTime?.format(context)}');
//                   print('Frequency: $frequency');
//                   print('Day Interval: $dayInterval');
//                   print('Week Interval: $weekInterval');
//                   print('Selected Days: $selectedDaysOfWeek');
//                   print('Month Interval: $monthInterval');
//                   print('Selected Day of Month: $selectedDayOfMonth');
//                   print('Year Interval: $yearInterval');
//                   print('Selected Month: $selectedMonth');
//                   print('End Date: $endDate');
//                 },
//                 child: const Icon(
//                   Icons.add,
//                   color: Colors.black, // ไอคอนสีดำ
//                   size: 30, // ขนาดไอคอน
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }