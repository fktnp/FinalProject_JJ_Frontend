import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentMonthRow extends StatefulWidget {
  final Function(DateTime) onDateChanged;

  const CurrentMonthRow({super.key, required this.onDateChanged});

  @override
  CurrentMonthRowState createState() => CurrentMonthRowState();
}

class CurrentMonthRowState extends State<CurrentMonthRow> {
  double width = 0.0;
  double height = 0.0;

  List<DateTime> monthsInYear = [];
  DateTime currentDateTime = DateTime.now();
  late PageController pageController;
  List<DateTime> yearsInRange = [];

  @override
  void initState() {
    super.initState();

    // สร้างเดือนในปีปัจจุบัน
    monthsInYear = _generateMonths(currentDateTime);
    yearsInRange = _generateYears(currentDateTime.year);

    // สร้าง PageController ด้วย initialPage เป็นเดือนปัจจุบัน
    pageController = PageController(initialPage: currentDateTime.month - 1, viewportFraction: 1);
  }

  List<DateTime> _generateMonths(DateTime baseDate) {
    return List.generate(12, (index) {
      return DateTime(baseDate.year, index + 1, 1); // สร้างวันที่ 1 ของแต่ละเดือน
    });
  }

  List<DateTime> _generateYears(int baseYear) {
    return List.generate(12, (index) {
      return DateTime(baseYear - 6 + index, 1, 1); // สร้างวันที่ 1 มกราคม ของแต่ละปี โดยเริ่มจากปีปัจจุบัน - 3 ถึง ปีปัจจุบัน + 3
    });
  }

  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Text(
        DateFormat('MMMM yyyy').format(currentDateTime),
        style: const TextStyle(
          color: Color.fromARGB(255, 26, 26, 26),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget sortTwelveYears() {
    return SizedBox(
      width: width,
      height: height * 0.1, // กำหนดความสูงของปี
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: yearsInRange.length,
        itemBuilder: (BuildContext context, int index) {
          return yearCapsuleView(index);
        },
      ),
    );
  }

  Widget sortTwelveMonths() {
    return SizedBox(
      width: width,
      height: height * 0.05, // กำหนดความสูงของเดือน
      child: ListView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemCount: monthsInYear.length,
        itemBuilder: (BuildContext context, int index) {
          return monthCapsuleView(index);
        },
      ),
    );
  }
  Widget monthCapsuleView(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentDateTime = monthsInYear[index];
        });
        widget.onDateChanged(monthsInYear[index]);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: (monthsInYear[index].month == currentDateTime.month)
              ? const Color(0xFFFFECDB) // สีน้ำเงินสำหรับเดือนปัจจุบัน
              : Colors.white.withOpacity(0.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('MMM').format(monthsInYear[index]),
                style: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: (monthsInYear[index].month == currentDateTime.month)
                      ? const Color.fromARGB(255, 26, 26, 26)
                      : const Color.fromARGB(255, 150, 150, 150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    Widget yearCapsuleView(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentDateTime = yearsInRange[index];
          
          // อัปเดต monthsInYear เป็นเดือนในปีที่เลือก
          monthsInYear = _generateMonths(currentDateTime);
        });
        widget.onDateChanged(yearsInRange[index]);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: (yearsInRange[index].year == currentDateTime.year)
              ? const Color(0xFFFFECDB) // สีสำหรับปีปัจจุบัน
              : Colors.white.withOpacity(0.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('yyyy').format(yearsInRange[index]),
                style: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: (yearsInRange[index].year == currentDateTime.year)
                      ? const Color.fromARGB(255, 26, 26, 26)
                      : const Color.fromARGB(255, 150, 150, 150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget topView() {
    return SizedBox(
      height: height * 0.2,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // CurrentYearRow(onDateChanged: widget.onDateChanged),
          titleView(),
          sortTwelveYears(),
          sortTwelveMonths(),

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

