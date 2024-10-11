import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '/utils/date_utils.dart' as date_util;
import 'task.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
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
                _currentView == 'day'
                    ? CurrentDayDateRow(
                        title: 'try',
                        onDateChanged: _onDateChanged,
                      )
                    : _currentView == 'month'
                        ? const CurrentMonthRow()
                        : const CurrentYearRow(),
                Expanded(
                  child: _currentView == 'day'
                      ? DayTimeTable(currentDate: currentDateTime)
                      : _currentView == 'month'
                          ? const MonthDaysTable()
                          : const YearTable(),
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

class CurrentDayDateRow extends StatefulWidget {
  final String title;
  final Function(DateTime) onDateChanged;

  const CurrentDayDateRow({
    super.key,
    required this.title,
    required this.onDateChanged,
  });

  @override
  CurrentDayDateRowState createState() => CurrentDayDateRowState();
}

class CurrentDayDateRowState extends State<CurrentDayDateRow> {
  double width = 0.0;
  double height = 0.0;
  late ScrollController scrollController;
  List<DateTime> multiMonthList = List.empty();
  DateTime currentDateTime = DateTime.now();

  @override
  void initState() {
    // Generate dates for the current, previous, and next 2 months
    multiMonthList = _generateMultiMonthDates(currentDateTime,
        monthsBefore: 2, monthsAfter: 2);
    scrollController =
        ScrollController(initialScrollOffset: 70.0 * currentDateTime.day);
    scrollController.addListener(_onScroll);
    super.initState();
  }

  // Function to generate dates across multiple months
  List<DateTime> _generateMultiMonthDates(DateTime baseDate,
      {int monthsBefore = 0, int monthsAfter = 0}) {
    List<DateTime> dateList = [];
    DateTime startDate =
        DateTime(baseDate.year, baseDate.month - monthsBefore, 1);
    DateTime endDate =
        DateTime(baseDate.year, baseDate.month + monthsAfter + 1, 0);

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      dateList.add(date);
    }

    return dateList;
  }

  void _onScroll() {
    if (scrollController.position.userScrollDirection == ScrollDirection.idle) {
      double offset = scrollController.offset;
      int index = (offset / (width * 0.14)).round();
      index = (index ~/ 7) * 7; // คำนวณเพื่อให้ล็อคอยู่ในช่วง 7 วัน

      if (index >= 0 && index < multiMonthList.length) {
        scrollController.animateTo(
          index * width * 0.14,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Text(
        '${date_util.DateUtils.months[currentDateTime.month - 1]} ${currentDateTime.year}',
        style: const TextStyle(
          color: Color.fromARGB(255, 26, 26, 26),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget sortSevenDay() {
    List<List<DateTime>> weeks = [];
    for (int i = 0; i < multiMonthList.length; i += 7) {
      weeks.add(multiMonthList.sublist(
          i, i + 7 > multiMonthList.length ? multiMonthList.length : i + 7));
    }

    return SizedBox(
      width: width * 1,
      height: height * 0.112,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1),
        itemCount: weeks.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weeks[index]
                .map((date) => capsuleView(multiMonthList.indexOf(date)))
                .toList(),
          );
        },
      ),
    );
  }

  Widget capsuleView(int index) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
            onTap: () {
              setState(() {
                currentDateTime = multiMonthList[index];
              });
              widget.onDateChanged(multiMonthList[index]);
            },
            child: Container(
              width: width * 0.1,
              decoration: BoxDecoration(
                color: (multiMonthList[index].day == currentDateTime.day &&
                        multiMonthList[index].month == currentDateTime.month)
                    ? const Color(0xFFFFECDB)
                    : Colors.white.withOpacity(0.0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      multiMonthList[index].day.toString(),
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color:
                            (multiMonthList[index].day != currentDateTime.day)
                                ? const Color.fromARGB(255, 26, 26, 26)
                                : const Color.fromARGB(255, 26, 26, 26),
                      ),
                    ),
                    Text(
                      date_util.DateUtils
                          .weekdays[multiMonthList[index].weekday - 1],
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color:
                            (multiMonthList[index].day != currentDateTime.day)
                                ? const Color.fromARGB(255, 26, 26, 26)
                                : const Color.fromARGB(255, 26, 26, 26),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget topView() {
    return SizedBox(
      height: height * 0.16,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          titleView(),
          sortSevenDay(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        topView(),
      ],
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}

class CurrentMonthRow extends StatefulWidget {
  const CurrentMonthRow({super.key});

  @override
  State<CurrentMonthRow> createState() => CurrentMonthRowState();
}

class CurrentMonthRowState extends State<CurrentMonthRow> {
  double width = 0.0;
  double height = 0.0;
  late ScrollController _scrollController;
  TextEditingController controller = TextEditingController();
  DateTime currentDateTime = DateTime.now();
  final months = date_util.DateUtils.getMonths();
  int selectedIndex = DateTime.now().month - 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset:
          50.0 * selectedIndex, // คำนวณให้เดือนปัจจุบันอยู่ตรงกลาง
    );
  }

  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Text(
        '${currentDateTime.year}',
        style: TextStyle(
          color: const Color.fromARGB(255, 26, 26, 26),
          fontWeight: FontWeight.bold,
          fontSize: height * 0.025, // ขนาด font = 0.025 ของความสูงหน้าจอ
        ),
      ),
    );
  }

  Widget capsuleView() {
    return Center(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: months.length,
          itemBuilder: (context, index) {
            final month = months[index];
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFECDB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  month,
                  style: TextStyle(
                    fontSize:
                        height * 0.025, // ขนาด font = 0.025 ของความสูงหน้าจอ
                    color: const Color.fromARGB(255, 26, 26, 26),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget topView() {
    return SizedBox(
      height: height * 0.16,
      width: width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            titleView(),
            capsuleView(),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        topView(),
      ],
    );
  }
}

class CurrentYearRow extends StatefulWidget {
  const CurrentYearRow({super.key});

  @override
  State<CurrentYearRow> createState() => CurrentYearRowState();
}

class CurrentYearRowState extends State<CurrentYearRow> {
  late ScrollController _scrollController;
  int selectedIndex = 10; // ปีปัจจุบันอยู่ตรงกลาง

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset:
          50.0 * selectedIndex, // คำนวณให้ปีปัจจุบันอยู่ตรงกลาง
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final height = MediaQuery.of(context).size.height;
    final years = date_util.DateUtils.getYears(now);

    return Center(
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFECDB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  year,
                  style: TextStyle(
                    fontSize:
                        height * 0.025, // ขนาด font = 0.025 ของความสูงหน้าจอ
                    color: const Color.fromARGB(255, 26, 26, 26),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class DayTimeTable extends StatefulWidget {
//   const DayTimeTable({super.key, required this.currentDate});
//   final DateTime currentDate;

//   @override
//   DayTimeTableState createState() => DayTimeTableState();
// }

// class DayTimeTableState extends State<DayTimeTable> {
//   late Future<List<Task>> tasksFuture;

//   @override
//   void initState() {
//     super.initState();
//     tasksFuture = loadTasks();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFFFECDB),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: FutureBuilder<List<Task>>(
//         future: tasksFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No tasks found'));
//           } else {
//             final tasks = snapshot.data!
//                 .where((task) =>
//                     task.taskDate.year == widget.currentDate.year &&
//                     task.taskDate.month == widget.currentDate.month &&
//                     task.taskDate.day == widget.currentDate.day)
//                 .toList();

//             return ListView.builder(
//               itemCount: 24,
//               itemBuilder: (context, index) {
//                 final time = '${index.toString().padLeft(2, '0')}:00';
//                 int number = 1;
//                 final tasksAtThisHour = tasks
//                     .where(
//                       (task) =>
//                           index >= task.taskStartHour &&
//                           index <= task.taskEndHour,
//                     )
//                     .toList();

//                 return Stack(
//                   children: [
//                     Row(
//                       children: [
//                         Padding(
//                           padding:
//                               EdgeInsets.fromLTRB(0, screenHeight * 0.08, 0, 0),
//                         ),
//                         Text(
//                           time,
//                           style: TextStyle(
//                             fontSize: screenHeight * 0.02,
//                             color: const Color.fromARGB(255, 26, 26, 26),
//                             decoration: TextDecoration.none,
//                           ),
//                         ),
//                         const LineForTable(),
//                       ],
//                     ),
//                     // Task ที่จะแสดงโดยให้ขอบบนชิดกับเส้นเวลาเริ่มต้น และขอบล่างชิดกับเส้นเวลาสิ้นสุด
//                     if (tasksAtThisHour.isNotEmpty)
//                       ...tasksAtThisHour.map((task) {
//                         return Positioned(
//                           top: (task.taskStartHour - index + 0.5) *
//                               screenHeight *
//                               0.08, // ชิดกับเส้นเริ่มต้น
//                           left: screenWidth * 0.15 +
//                               (screenWidth * 0.28 * number),
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Row(
//                               children: tasksAtThisHour
//                                   .map((task) => AddedDayTask(
//                                       task: task,
//                                       boxheight: (task.taskEndHour -
//                                               task.taskStartHour) *
//                                           screenHeight *
//                                           0.08))
//                                   .toList(),
//                             ),
//                           ),
//                         );
//                       }),
//                   ],
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class DayTimeTable extends StatefulWidget {
//   const DayTimeTable({super.key, required this.currentDate});
//   final DateTime currentDate;

//   @override
//   DayTimeTableState createState() => DayTimeTableState();
// }

// class DayTimeTableState extends State<DayTimeTable> {
//   late Future<List<Task>> tasksFuture;
//   late List<int> taskCounters; // ประกาศ taskCounters

//   @override
//   void initState() {
//     super.initState();
//     tasksFuture = loadTasks();
//     resetTaskCounters(); // เคลียร์ค่าตัวแปรเมื่อเปิดหน้านี้ใหม่
//   }

//   void resetTaskCounters() {
//     // รีเซ็ต taskCounters เป็น 0 สำหรับทุกชั่วโมง
//     taskCounters = List.filled(24, 0);
//   }

//   void updateTaskCounters(List<Task> tasks) {
//     // รีเซ็ตค่าเมื่อโหลดข้อมูลสำเร็จ
//     resetTaskCounters();

//     // อัปเดต taskCounters ตาม task ที่มีในแต่ละช่วงเวลา
//     for (var task in tasks) {
//       for (int i = task.taskStartHour; i <= task.taskEndHour; i++) {
//         taskCounters[i]++;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFFFECDB),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: FutureBuilder<List<Task>>(
//         future: tasksFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No tasks found'));
//           } else {
//             final tasks = snapshot.data!
//                 .where((task) =>
//                     task.taskDate.year == widget.currentDate.year &&
//                     task.taskDate.month == widget.currentDate.month &&
//                     task.taskDate.day == widget.currentDate.day)
//                 .toList();

//             // อัปเดต taskCounters ทุกครั้งที่มีการโหลดข้อมูลสำเร็จ
//             updateTaskCounters(tasks);

//             return ListView.builder(
//               itemCount: 24,
//               itemBuilder: (context, index) {
//                 final time = '${index.toString().padLeft(2, '0')}:00';
//                 int howMuch = 0;
//                 int number =
//                     taskCounters[index]; // ใช้ค่า number จาก taskCounters

//                 final tasksAtThisHour = tasks
//                     .where(
//                       (task) =>
//                           index >= task.taskStartHour &&
//                           index <= task.taskEndHour,
//                     )
//                     .toList();

//                 return Stack(
//                   children: [
//                     Row(
//                       children: [
//                         Padding(
//                           padding:
//                               EdgeInsets.fromLTRB(0, screenHeight * 0.08, 0, 0),
//                         ),
//                         Text(
//                           '$time (number: $number)', // แสดงค่า number ที่อัปเดตแล้ว
//                           style: TextStyle(
//                             fontSize: screenHeight * 0.02,
//                             color: const Color.fromARGB(255, 26, 26, 26),
//                             decoration: TextDecoration.none,
//                           ),
//                         ),
//                         const LineForTable(),
//                       ],
//                     ),
//                     // Task ที่จะแสดงโดยให้ขอบบนชิดกับเส้นเวลาเริ่มต้น และขอบล่างชิดกับเส้นเวลาสิ้นสุด
//                     if (tasksAtThisHour.isNotEmpty)
//                       ...tasksAtThisHour.map((task) {
//                         // ตรวจสอบค่า number ที่สูงที่สุดในแต่ละช่วงเวลาที่ task ครอบคลุม
//                         int maxNumber = 0;
//                         for (int i = task.taskStartHour;
//                             i <= task.taskEndHour;
//                             i++) {
//                           if (taskCounters[i] > maxNumber) {
//                             maxNumber =
//                                 taskCounters[i]; // หาค่า number ที่สูงที่สุด
//                           }
//                         }

//                         // หลังจากที่ได้ maxNumber ให้ใช้ในการจัดวาง task ในแต่ละช่วงเวลาที่มันครอบคลุม
//                         for (int i = task.taskStartHour;
//                             i <= task.taskEndHour;
//                             i++) {
//                           taskCounters[i] =
//                               maxNumber; // ใช้ค่า maxNumber สำหรับแต่ละช่วงเวลา
//                         }

//                         return Positioned(
//                           top: (task.taskStartHour - index + 0.5) *
//                               screenHeight *
//                               0.08, // ชิดกับเส้นเริ่มต้น
//                           left: screenWidth * 0.15 +
//                               (screenWidth *
//                                   0.28 *
//                                   maxNumber), // วาง task ตามค่า maxNumber
//                           child: Stack(
//                             children: tasksAtThisHour
//                                 .map((task) => AddedDayTask(
//                                     task: task,
//                                     boxheight: (task.taskEndHour -
//                                             task.taskStartHour) *
//                                         screenHeight *
//                                         0.08))
//                                 .toList(),
//                           ),
//                         );
//                       }),
//                   ],
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class DayTimeTable extends StatefulWidget {
  const DayTimeTable({super.key, required this.currentDate});
  final DateTime currentDate;

  @override
  DayTimeTableState createState() => DayTimeTableState();
}

class DayTimeTableState extends State<DayTimeTable> {
  late Future<List<Task>> tasksFuture;
  List<int> numbers = List.filled(24, 0); // ตัวแปรนับจำนวน task ในแต่ละช่วงเวลา

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  void resetNumbers() {
    // รีเซ็ตค่าตัวแปร numbers ทุกครั้งที่โหลด task ใหม่
    setState(() {
      numbers = List.filled(24, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFECDB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          } else {
            // รีเซ็ตตัวแปร numbers ที่นี่เพื่อให้ค่าเริ่มต้นเป็น 0
            WidgetsBinding.instance.addPostFrameCallback((_) {
              resetNumbers();
            });

            final tasks = snapshot.data!
                .where((task) =>
                    task.taskDate.year == widget.currentDate.year &&
                    task.taskDate.month == widget.currentDate.month &&
                    task.taskDate.day == widget.currentDate.day)
                .toList();

            return ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final time = '${index.toString().padLeft(2, '0')}:00';

                final tasksAtThisHour = tasks
                    .where(
                      (task) =>
                          index >= task.taskStartHour &&
                          index <= task.taskEndHour,
                    )
                    .toList();

                return Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.fromLTRB(0, screenHeight * 0.08, 0, 0),
                        ),
                        Text(
                          time, // แสดงค่า number ที่เริ่มต้นเป็น 0
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(255, 26, 26, 26),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const LineForTable(),
                      ],
                    ),
                    // Task ที่จะแสดงโดยให้ขอบบนชิดกับเส้นเวลาเริ่มต้น และขอบล่างชิดกับเส้นเวลาสิ้นสุด
                    if (tasksAtThisHour.isNotEmpty)
                      ...tasksAtThisHour.map((task) {
                        int quantity = 0;
                        if (task.taskName == "WTF") {
                          quantity = 1;
                          numbers[task.taskStartHour] = quantity;
                        } else {
                          quantity = 0;
                        }

                        return Positioned(
                          top: (task.taskStartHour - index + 0.5) *
                              screenHeight *
                              0.08, // ชิดกับเส้นเริ่มต้น
                          left: screenWidth * 0.15 +
                              (screenWidth *
                                  0.30 *
                                  quantity), // วาง task ตามค่า number
                          child: Stack(
                            children: tasksAtThisHour
                                .map((task) => AddedDayTask(
                                    task: task,
                                    boxheight: (task.taskEndHour -
                                            task.taskStartHour) *
                                        screenHeight *
                                        0.08))
                                .toList(),
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MonthDaysTable extends StatelessWidget {
  const MonthDaysTable({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final now = DateTime.now();
    final days = getMonthDays(now);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFECDB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: screenWidth * 0.02,
                            right: screenWidth * 0.02),
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFDCBC),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${days[index]['date']}",
                              style: TextStyle(
                                fontSize: screenHeight * 0.022,
                                color: const Color.fromARGB(255, 26, 26, 26),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              "${days[index]['day']}",
                              style: TextStyle(
                                fontSize: screenHeight * 0.022,
                                color: const Color.fromARGB(255, 26, 26, 26),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      )
                    ],
                  ),
                  const LineForTable()
                ],
              )
              //add task
            ],
          );
        },
      ),
    );
  }

  List<Map<String, String>> getMonthDays(DateTime currentDate) {
    final days = <Map<String, String>>[];
    final formatter = DateFormat('dd');
    final dayFormatter = DateFormat('EEE'); // ใช้ 'EEE' เพื่อแสดงตัวย่อของวัน

    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

    for (int i = 0; i < lastDayOfMonth.day; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      days.add({
        'date': formatter.format(date),
        'day': dayFormatter.format(date),
      });
    }
    return days;
  }
}

class YearTable extends StatelessWidget {
  const YearTable({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.015),
      decoration: const BoxDecoration(
        color: Color(0xFFFFECDB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthDate = DateTime(DateTime.now().year, index + 1, 1);
          final monthName =
              DateFormat('MMMM').format(monthDate); // ชื่อเดือนแบบเต็ม

          return Column(
            children: [
              ListTile(
                  key: ValueKey(monthDate),
                  title: Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.25,
                        child: Text(
                          monthName,
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: const Color.fromARGB(255, 26, 26, 26),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.06,
                      ),
                      // const AddedTask(),
                    ],
                  )),
              // const LineForTable()
            ],
          );
        },
      ),
    );
  }
}

class LineForTable extends StatelessWidget {
  const LineForTable({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Expanded(
      child: Divider(
        color: const Color.fromARGB(255, 43, 42, 42),
        thickness: screenHeight * 0.001,
      ),
    );
  }
}
