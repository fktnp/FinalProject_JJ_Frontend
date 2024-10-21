import 'package:flutter/material.dart';
import 'package:flutter_application_1/sub_components_calendar/DayDateRow.dart';
import 'package:flutter_application_1/sub_components_calendar/MonthDateRow.dart';
import 'package:flutter_application_1/sub_components_calendar/YearDateRow.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math';


class MyCalendarView extends StatefulWidget {
  const MyCalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<MyCalendarView> {
  String _currentView = 'day';
  DateTime currentDateTime = DateTime.now();
  late CalendarController _calendarController;
  late CalendarDataSource _calendarDataSource; // Declare a CalendarDataSource

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _generateSampleTasks(); // Create sample tasks
  }

  void _generateSampleTasks() {
    List<Appointment> appointments = []; // Create a local appointments list
    Random random = Random(); // Create a Random object
    DateTime now = DateTime.now();

    for (int i = 0; i < 10; i++) {
      // Randomly select a number of days from -10 to +10
      int randomDays = random.nextInt(21) - 10; // Generates a number between -10 and 10

      // Randomly select a start hour
      int randomHour = random.nextInt(24); // Generates a number between 0 and 23

      // Randomly select a duration between 1 to 3 hours
      int randomDuration = random.nextInt(3) + 1; // Generates a number between 1 and 3

      appointments.add(Appointment(
        startTime: DateTime(now.year, now.month, now.day)
            .add(Duration(days: randomDays))
            .add(Duration(hours: randomHour)), // Random hour
        endTime: DateTime(now.year, now.month, now.day)
            .add(Duration(days: randomDays))
            .add(Duration(hours: randomHour + randomDuration)), // End time based on random duration
        subject: 'Task ${i + 1}', // Task name
        color: Colors.blue, // Task color
        isAllDay: false, // Not an all-day event
      ));
    }
    _calendarDataSource = AppointmentDataSource(appointments); // Initialize the data source
  }

  void _onViewChanged(String view) {
    setState(() {
      _currentView = view;
      switch (view) {
        case 'day':
          _calendarController.view = CalendarView.day;
          break;
        case 'month':
          _calendarController.view = CalendarView.month;
          break;
        case 'year':
          _calendarController.view = CalendarView.schedule;
          break;
      }
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      currentDateTime = date;
      _calendarController.displayDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        color: const Color(0xFFFFECDB),
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.05),
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.95,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDCBC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToggleButton('Day', 'day', screenWidth, screenHeight),
                    _buildToggleButton('Month', 'month', screenWidth, screenHeight),
                    _buildToggleButton('Year', 'year', screenWidth, screenHeight),
                  ],
                ),
                _currentView == 'day'
                    ? CurrentDayDateRow(
                        title: 'try',
                        onDateChanged: _onDateChanged,
                        tragetDateShow: currentDateTime,
                      )
                    : _currentView == 'month'
                        ? CurrentMonthRow(onDateChanged: _onDateChanged,)
                        : CurrentYearRow(onDateChanged: _onDateChanged,),
                Expanded(
                  child: SfCalendar(
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeTextStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      timeFormat: 'HH:mm',
                    ),
                    controller: _calendarController,
                    view: _currentView == 'day'
                        ? CalendarView.day
                        : _currentView == 'month'
                            ? CalendarView.month
                            : CalendarView.schedule,
                    initialDisplayDate: currentDateTime,
                    headerHeight: 0, // Hide header
                    onTap: (CalendarTapDetails details) {
                          if (details.targetElement == CalendarElement.calendarCell || 
                              details.targetElement == CalendarElement.appointment){
                            // Set the selected date in the controller
                            _calendarController.displayDate = details.date!;
                            // Change the view to day
                            _onViewChanged('day');
                            // Update the current date
                            _onDateChanged(details.date!);
                          }
                        },
                    dataSource: _calendarDataSource, // Set the data source here
                    scheduleViewSettings: const ScheduleViewSettings(
                      monthHeaderSettings: MonthHeaderSettings(
                        backgroundColor: Colors.black,
                        //ไว้แต่งหน้าไอแถบ ดำๆ หน้า  year เพิ่มนะ
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, String view, double screenWidth, double screenHeight) {
    final isActive = _currentView == view;
    return GestureDetector(
      onTap: () => _onViewChanged(view),
      child: Container(
        width: screenWidth * 0.25,
        height: screenHeight * 0.07,
        margin: EdgeInsets.only(top: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFECDB) : const Color(0xFFFFDCBC),
          borderRadius: BorderRadius.circular(15.0),
          border: isActive
              ? Border.all(color: const Color(0xFF000000), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenHeight * 0.03,
              color: isActive
                  ? const Color.fromARGB(255, 26, 26, 26)
                  : const Color.fromARGB(255, 150, 150, 150),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom CalendarDataSource class to hold appointments
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
