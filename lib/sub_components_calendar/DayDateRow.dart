import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

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

  List<DateTime> multiMonthList = List.empty();
  DateTime currentDateTime = DateTime.now();
  late PageController pageController;


  @override
  void initState() {
    // Generate dates for the current, previous, and next 2 months
    multiMonthList = _generateMultiMonthDates(currentDateTime, monthsBefore: 2, monthsAfter: 2);
    
    super.initState();

    // คำนวณ weekIndex
    int weekIndex = calculateWeekIndex(multiMonthList, currentDateTime);
    
    // สร้าง PageController ด้วย initialPage เป็น 0
    pageController = PageController(initialPage: 0, viewportFraction: 1);
    
    // เลื่อนหน้าไปที่ weekIndex
    Future.delayed(Duration.zero, () {
      pageController.animateToPage(
        weekIndex,
        duration: Duration(milliseconds: 800), // ระยะเวลาในการเลื่อน
        curve: Curves.easeInOut, // รูปแบบการเคลื่อนไหว
      );
    });
  }

  // Function to generate dates across multiple months
  List<DateTime> _generateMultiMonthDates(DateTime baseDate, {int monthsBefore = 2, int monthsAfter = 2}) {
    List<DateTime> dateList = [];
    
    // คำนวณวันเริ่มต้นและวันสิ้นสุด
    DateTime startDate = DateTime(baseDate.year, baseDate.month - monthsBefore, 1);
    DateTime endDate = DateTime(baseDate.year, baseDate.month + monthsAfter + 1, 0);

    // เพิ่มวันที่ในระยะเวลา
    for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
      dateList.add(date);
    }

    return dateList;
  }


  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Text(
        '${DateFormat('dd MMMM yyyy').format(currentDateTime)}', // ใช้ DateFormat จาก intl
        style: const TextStyle(
          color: Color.fromARGB(255, 26, 26, 26),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  int calculateWeekIndex(List<DateTime> multiMonthList, DateTime currentDateTime) {
    // คำนวณ index ของวันปัจจุบัน
    int currentDayIndex = multiMonthList.indexWhere((date) =>
        date.year == currentDateTime.year &&
        date.month == currentDateTime.month &&
        date.day == currentDateTime.day);
    
    // หาจำนวนสัปดาห์
    return currentDayIndex >= 0 ? currentDayIndex ~/ 7 : 0;
  }

  
  Widget sortSevenDay() {
    List<List<DateTime>> weeks = [];
    for (int i = 0; i < multiMonthList.length; i += 7) {
      weeks.add(multiMonthList.sublist(i, i + 7 > multiMonthList.length ? multiMonthList.length : i + 7));
    }

    // int weekIndex = calculateWeekIndex(multiMonthList, currentDateTime);

    // // สร้าง PageController ด้วย initialPage เป็น weekIndex เลื่อนไป index array หน้านั้นเลยอ้ะ!
    // pageController = PageController(initialPage: weekIndex,viewportFraction : 1);


    return SizedBox(
      width: width * 1,
      height: height * 0.112,
      child: PageView.builder(
        controller: pageController,
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
                      DateFormat('MMM').format(multiMonthList[index]),
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: (multiMonthList[index].day != currentDateTime.day)
                            ? const Color.fromARGB(255, 26, 26, 26)
                            : const Color.fromARGB(255, 26, 26, 26),
                      ),
                    ),
                    Text(
                      multiMonthList[index].day.toString(),
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: (multiMonthList[index].day != currentDateTime.day)
                            ? const Color.fromARGB(255, 26, 26, 26)
                            : const Color.fromARGB(255, 26, 26, 26),
                      ),
                    ),
                    Text(
                      DateFormat('EEE').format(multiMonthList[index]),
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: (multiMonthList[index].day != currentDateTime.day)
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

    return topView();
  }

  @override
  void dispose() {
    pageController.dispose(); // อย่าลืม dispose pageController
    super.dispose();
  }

}

class CurrentMonthRow extends StatelessWidget {
  const CurrentMonthRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add your month row implementation here
      child: const Text('Current Month Row'),
    );
  }
}

class CurrentYearRow extends StatelessWidget {
  const CurrentYearRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add your year row implementation here
      child: const Text('Current Year Row'),
    );
  }
}
