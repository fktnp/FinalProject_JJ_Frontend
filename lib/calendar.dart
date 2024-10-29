import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/calendarModel.dart';
import 'package:flutter_application_1/model/subJobModel.dart';
import 'package:flutter_application_1/sub_components_calendar/daydaterow.dart';
import 'package:flutter_application_1/sub_components_calendar/monthdaterow.dart';
import 'package:flutter_application_1/sub_components_calendar/yeardaterow.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'model/theme.dart';

class MyCalendarView extends StatefulWidget {
  const MyCalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<MyCalendarView> {
  String _currentView = 'day';
  String? userId;
  late DateTime currentDateTime;
  late CalendarController _calendarController;
  late CalendarDataSource _calendarDataSource; // Declare a CalendarDataSource

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    _calendarController = CalendarController();
    _calendarDataSource =
        AppointmentDataSource([]); // Initialize with empty data
    _readUserIdFromSharedPrefs();
    _generateSampleTasks(); // Create sample tasks
  }

  Future<void> _readUserIdFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId == null) {
      // Handle case where user_id is not found
      print('Error: user_id not found in SharedPreferences');
    } else {
      // userId is available, proceed with API call
      print('user_id: $userId');
    }
  }

  Future<List<CalendarModel>> fetchCalendarData() async {
    final Dio dio = Dio();
    final String url =
        'http://10.0.2.2:8080/v1/calendar/user/$userId'; // แทนที่ด้วย URL จริง

    if (userId == null) {
      // Handle case where user_id is not found
      throw Exception('user_id is not available');
    }

    final response = await dio.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => CalendarModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load calendar data');
    }
  }

  Future<SubJobModel> fetchSubJob(String subJobID) async {
    final Dio dio = Dio();
    final response = await dio.get(
        'http://10.0.2.2:8080/v1/subjob/$subJobID'); // เปลี่ยน URL ตามที่คุณใช้

    if (response.statusCode == 200) {
      return SubJobModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load subjob');
    }
  }

  void _generateSampleTasks() async {
    try {
      List<CalendarModel> calendars =
          await fetchCalendarData(); // ดึงข้อมูลจาก API
      List<Appointment> appointments = [];
      print("calendar $calendars");
      for (var calendar in calendars) {
        SubJobModel subJob = await fetchSubJob(
            calendar.subJobID); // ดึงข้อมูล SubJob ตาม subJobID
        print("subJobs $subJob");

        DateTime currentstartTime = DateTime(
          calendar.dateCalendar.year, // เอาปีจาก calendar
          calendar.dateCalendar.month, // เอาเดือนจาก calendar
          calendar.dateCalendar.day, // เอาวันจาก calendar
          subJob.startTimeGoal.hour, // เอาเวลาชั่วโมงจาก subJob
          subJob.startTimeGoal.minute, // เอาเวลานาทีจาก subJob
        );

        DateTime currentendTime = DateTime(
          calendar.dateCalendar.year, // เอาปีจาก calendar
          calendar.dateCalendar.month, // เอาเดือนจาก calendar
          calendar.dateCalendar.day, // เอาวันจาก calendar
          subJob.lastTimeGoal.hour, // เอาเวลาชั่วโมงจาก subJob
          subJob.lastTimeGoal.minute, // เอาเวลานาทีจาก subJob
        );

        appointments.add(Appointment(
          startTime: currentstartTime, // ใช้ startTimeGoal จาก SubJob
          endTime: currentendTime, // ใช้ lastTimeGoal จาก SubJob
          subject: subJob.name, // ใช้ชื่อของ SubJob
          color: subJob.status == 'completed'
              ? const Color.fromARGB(255, 190, 255, 201)
              : const Color.fromARGB(255, 190, 223, 255), // ใช้สีตามสถานะ
          isAllDay: false,
        ));
      }

      _calendarDataSource =
          AppointmentDataSource(appointments); // สร้าง CalendarDataSource
      setState(() {}); // อัปเดต UI
    } catch (e) {
      print("log Error");
      print('Error: $e');
    }
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        color: pastel.pastel2,
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.05),
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.95,
            decoration: BoxDecoration(
              color: pastel.pastel1,
              borderRadius: const BorderRadius.only(
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
                _currentView == 'day'
                    ? CurrentDayDateRow(
                        title: 'try',
                        onDateChanged: _onDateChanged,
                        tragetDateShow: currentDateTime,
                      )
                    : _currentView == 'month'
                        ? CurrentMonthRow(
                            onDateChanged: _onDateChanged,
                          )
                        : CurrentYearRow(
                            onDateChanged: _onDateChanged,
                          ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        color: pastel.pastel2,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: SfCalendar(
                        timeSlotViewSettings: TimeSlotViewSettings(
                          timeTextStyle: TextStyle(
                            fontSize: 14,
                            color: pastel.pastelFont,
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
                          if (details.targetElement ==
                                  CalendarElement.calendarCell ||
                              details.targetElement ==
                                  CalendarElement.appointment) {
                            // Set the selected date in the controller
                            _calendarController.displayDate = details.date!;
                            // _calendarController.selectedDate = DateTime.now();
                            // Change the view to day
                            _onViewChanged('day');
                            // Update the current date
                            _onDateChanged(details.date!);
                          }
                        },
                        dataSource:
                            _calendarDataSource, // Set the data source here
                        scheduleViewSettings: ScheduleViewSettings(
                            appointmentTextStyle: TextStyle(
                                color: pastel.pastelFont,
                                fontWeight: FontWeight.bold),
                            monthHeaderSettings: MonthHeaderSettings(
                                backgroundColor: pastel.pastel1 ??
                                    const Color.fromARGB(255, 41, 41, 41),
                                height: 60,
                                textAlign: TextAlign.center,
                                monthTextStyle: TextStyle(
                                  color: pastel.pastelFont,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )
                                //ไว้แต่งหน้าไอแถบ ดำๆ หน้า  year เพิ่มนะ
                                ),
                            weekHeaderSettings: WeekHeaderSettings(
                              weekTextStyle: TextStyle(
                                  color: pastel.pastelFont,
                                  fontWeight: FontWeight.bold),
                            ),
                            dayHeaderSettings: DayHeaderSettings(
                                dayTextStyle: TextStyle(
                                  color: pastel.pastelFont,
                                ),
                                dateTextStyle: TextStyle(
                                    color: pastel.pastelFont,
                                    fontWeight: FontWeight.bold)))),
                  ),
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    final isActive = _currentView == view;
    return GestureDetector(
      onTap: () => _onViewChanged(view),
      child: Container(
        width: screenWidth * 0.25,
        height: screenHeight * 0.07,
        margin: EdgeInsets.only(top: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: isActive ? pastel.pastel2 : pastel.pastel1,
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
                  ? pastel.pastelFont
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
