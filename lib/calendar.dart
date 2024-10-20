import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyCalendarView extends StatefulWidget {
  const MyCalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<MyCalendarView> {
  String _currentView = 'day';
  DateTime currentDateTime = DateTime.now();

  void _onViewChanged(String view) {
    setState(() {
      _currentView = view;
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      currentDateTime = date;
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
                    _buildToggleButton(
                        'Month', 'month', screenWidth, screenHeight),
                    _buildToggleButton(
                        'Year', 'year', screenWidth, screenHeight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      String text, String view, double screenWidth, double screenHeight) {
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
