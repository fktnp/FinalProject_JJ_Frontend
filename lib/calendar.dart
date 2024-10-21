import 'package:flutter/material.dart';
import 'package:flutter_application_1/sub_components_calendar/DayDateRow.dart';
import 'package:flutter_application_1/sub_components_calendar/MonthDateRow.dart';
import 'package:flutter_application_1/sub_components_calendar/YearDateRow%20copy%202.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyCalendarView extends StatefulWidget {
  const MyCalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<MyCalendarView> {
  String _currentView = 'day';
  DateTime currentDateTime = DateTime.now();
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
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
      // _calendarController.selectedDate = date;
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
                    headerHeight: 0, // ซ่อน header โดยตั้งค่า height เป็น 0
                    onTap: (CalendarTapDetails details) {
                      if (details.targetElement == CalendarElement.calendarCell) {
                        _onDateChanged(details.date!);
                      }
                    },
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
