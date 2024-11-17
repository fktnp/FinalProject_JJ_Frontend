import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/calendarModel.dart';
import 'package:flutter_application_1/model/subJobModel.dart';
import 'package:flutter_application_1/sub_components_calendar/daydaterow.dart';
import 'package:flutter_application_1/sub_components_calendar/monthdaterow.dart';
import 'package:flutter_application_1/sub_components_calendar/yeardaterow.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'model/theme.dart';

class MyCalendarView extends StatefulWidget {
  final String userId;
  const MyCalendarView({super.key, required this.userId});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<MyCalendarView> {
  String _currentView = 'day';
  late DateTime currentDateTime;
  late CalendarController _calendarController;
  late CalendarDataSource _calendarDataSource;
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    _calendarController = CalendarController();
    _calendarDataSource = AppointmentDataSource([]);
    _initializationFuture = _generateSampleTasks();
  }

  Future<List<CalendarModel>> fetchCalendarData() async {
    final Dio dio = Dio();
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final String url = '$apiUrl/v1/calendar/user/${widget.userId}';

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
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final response = await dio.get('$apiUrl/v1/subjob/$subJobID');

    if (response.statusCode == 200) {
      return SubJobModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load subjob');
    }
  }

  Future<List<SubJobModel>> fetchAllSubJob() async {
    final Dio dio = Dio();
    // ตรวจสอบให้แน่ใจว่า URL ถูกต้อง
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    String url =
        '$apiUrl/v1/subjob/user/${widget.userId}'; // เพิ่ม 'user' ในพาท

    try {
      // กำหนดค่า validateStatus เพื่อไม่ให้ throw error ทันที
      final response = await dio.get(
        url,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // ยอมรับ status code ที่ต่ำกว่า 500
          },
        ),
      );

      // ตรวจสอบ response status และ data
      if (response.statusCode == 200 && response.data != null) {
        // print(
        //     'Response data: ${response.data}'); // เพิ่ม log เพื่อดูข้อมูลที่ได้

        if (response.data is List) {
          final List<dynamic> taskListJson = response.data;
          return taskListJson
              .map((json) => SubJobModel.fromJson(json))
              .toList();
        } else {
          // ถ้าข้อมูลไม่ใช่ List
          print('Invalid data format: ${response.data}');
          return []; // ส่งคืน List ว่าง
        }
      } else {
        print('Server response: ${response.statusCode} - ${response.data}');
        return []; // ส่งคืน List ว่างถ้าไม่มีข้อมูล
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');
      return []; // ส่งคืน List ว่างในกรณีที่มี error
    } catch (e) {
      print('Unexpected error: $e');
      return []; // ส่งคืน List ว่างในกรณีที่มี error อื่นๆ
    }
  }

  String _getRecurrenceRule(SubJobModel subJob) {
    if (subJob.frequency == 'daily') {
      return 'FREQ=DAILY;INTERVAL=${subJob.frequencyDay};UNTIL=${subJob.lastDate.toIso8601String()}';
    } else if (subJob.frequency == 'weekly') {
      String daysOfWeek = subJob.frequencyWeek.map((day) {
        switch (day) {
          case 'Sunday':
            return 'SU';
          case 'Monday':
            return 'MO';
          case 'Tuesday':
            return 'TU';
          case 'Wednesday':
            return 'WE';
          case 'Thursday':
            return 'TH';
          case 'Friday':
            return 'FR';
          case 'Saturday':
            return 'SA';
          default:
            return '';
        }
      }).join(',');

      return 'FREQ=WEEKLY;BYDAY=$daysOfWeek;UNTIL=${subJob.lastDate.toIso8601String()}';
    } else if (subJob.frequency == 'monthly') {
      return 'FREQ=MONTHLY;BYMONTHDAY=${subJob.frequencyMonth.join(',')};UNTIL=${subJob.lastDate.toIso8601String()}';
    } else {
      return '';
    }
  }

  Future<void> _generateSampleTasks() async {
    try {
      // เปลี่ยนจาก fetchCalendarData() เป็น fetchAllSubJob()
      List<SubJobModel> subJobs = await fetchAllSubJob();
      List<Appointment> appointments = [];

      for (var subJob in subJobs) {
        // ใช้วันที่จาก subJob.startDate โดยตรง
        DateTime currentstartTime = DateTime(
          subJob.startDate.year,
          subJob.startDate.month,
          subJob.startDate.day,
          subJob.startTimeGoal.hour,
          subJob.startTimeGoal.minute,
        );

        DateTime currentendTime = DateTime(
          subJob.startDate.year,
          subJob.startDate.month,
          subJob.startDate.day,
          subJob.lastTimeGoal.hour,
          subJob.lastTimeGoal.minute,
        );

        appointments.add(Appointment(
          startTime: currentstartTime,
          endTime: currentendTime,
          subject: subJob.name,
          recurrenceRule: _getRecurrenceRule(subJob),
          color: subJob.status == 'completed'
              ? const Color.fromARGB(255, 155, 255, 172)
              : const Color.fromARGB(255, 190, 223, 255),
          isAllDay: false,
        ));
      }
      _calendarDataSource = AppointmentDataSource(appointments);
    } catch (e) {
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
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              overflow: TextOverflow.ellipsis,
              'Error: ${snapshot.error}',
            ));
          }

          return Container(
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
                        _buildToggleButton(
                            AppLocalizations.of(context).translate('day'),
                            'day',
                            screenWidth,
                            screenHeight),
                        _buildToggleButton(
                            AppLocalizations.of(context).translate('month'),
                            'month',
                            screenWidth,
                            screenHeight),
                        _buildToggleButton(
                            AppLocalizations.of(context).translate('year'),
                            'year',
                            screenWidth,
                            screenHeight),
                      ],
                    ),
                    _currentView == 'day'
                        ? CurrentDayDateRow(
                            title: 'try',
                            onDateChanged: _onDateChanged,
                            tragetDateShow: currentDateTime,
                          )
                        : _currentView == 'month'
                            ? CurrentMonthRow(onDateChanged: _onDateChanged)
                            : CurrentYearRow(onDateChanged: _onDateChanged),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: pastel.pastel2,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        child: SfCalendar(
                            timeSlotViewSettings: TimeSlotViewSettings(
                              timeTextStyle: TextStyle(
                                fontSize: screenWidth * 0.035,
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
                            headerHeight: 0,
                            onTap: (CalendarTapDetails details) {
                              if (details.targetElement ==
                                      CalendarElement.calendarCell ||
                                  details.targetElement ==
                                      CalendarElement.appointment) {
                                _calendarController.displayDate = details.date!;
                                _onViewChanged('day');
                                _onDateChanged(details.date!);
                              }
                            },
                            dataSource: _calendarDataSource,
                            appointmentTextStyle: TextStyle(
                              color: pastel.pastelFont,
                              fontSize: screenWidth * 0.027,
                            ),
                            appointmentBuilder: (BuildContext context,
                                CalendarAppointmentDetails details) {
                              final Appointment appointment =
                                  details.appointments.first;

                              return Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment
                                    .centerLeft, // ตำแหน่งตัวอักษรใน Appointment
                                decoration: BoxDecoration(
                                  color: appointment.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  appointment.subject,
                                  style: TextStyle(
                                    fontSize:
                                        screenWidth * 0.04, // ขนาดตัวอักษร
                                    color: pastel.pastelFont, // สีตัวอักษร
                                    fontWeight:
                                        FontWeight.bold, // น้ำหนักตัวอักษร
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
            overflow: TextOverflow.ellipsis,
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
