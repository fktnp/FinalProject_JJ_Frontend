import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/theme.dart';

class CurrentYearRow extends StatefulWidget {
  final Function(DateTime) onDateChanged;

  const CurrentYearRow({super.key, required this.onDateChanged});

  @override
  CurrentYearRowState createState() => CurrentYearRowState();
}

class CurrentYearRowState extends State<CurrentYearRow> {
  double width = 0.0;
  double height = 0.0;

  List<DateTime> yearsInRange = [];
  DateTime currentDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // สร้างปีในช่วงที่กำหนด
    yearsInRange = _generateYears(currentDateTime.year);
  }

  List<DateTime> _generateYears(int baseYear) {
    return List.generate(12, (index) {
      return DateTime(baseYear - 6 + index, 1,
          1); // สร้างวันที่ 1 มกราคม ของแต่ละปี โดยเริ่มจากปีปัจจุบัน - 3 ถึง ปีปัจจุบัน + 3
    });
  }

  Widget titleView() {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Text(
        DateFormat('yyyy').format(currentDateTime),
        style: TextStyle(
          color: pastel.pastelFont,
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

  Widget yearCapsuleView(int index) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentDateTime = yearsInRange[index];
        });
        widget.onDateChanged(yearsInRange[index]);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: (yearsInRange[index].year == currentDateTime.year)
              ? pastel.pastel2 // สีสำหรับปีปัจจุบัน
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
                      ? pastel.pastelFont
                      : pastel.pastelFont2,
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
          titleView(),
          sortTwelveYears(),
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
}
