import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../model/mainjobmodel.dart';
import '../model/theme.dart';

class CustomPopup extends StatefulWidget {
  final MainJobModel mainJobModel;

  const CustomPopup({super.key, required this.mainJobModel});

  @override
  _CustomPopupState createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  final TextEditingController _inputController = TextEditingController();
  Color _backgroundColor = Colors.white;
  String _message = "Enter a percentage to calculate";

  void _calculateAndChange(int inputPercentage) async {
    Navigator.of(context).pop();
    try {
      DateTime startTime = widget.mainJobModel.startTimeGoal;
      DateTime lastTime = widget.mainJobModel.lastTimeGoal;
      int totalDays = lastTime.difference(startTime).inDays;

      if (totalDays <= 0) {
        setState(() {
          _message = "Invalid goal duration! Please check the dates.";
          _backgroundColor = Colors.red.shade200;
        });
        return;
      }

      DateTime now = DateTime.now();
      int remainingDays = lastTime.difference(now).inDays;
      if (remainingDays < 0) remainingDays = 0;

      double remainingTimePercentage = (remainingDays / totalDays) * 100;
      double kValue = inputPercentage / (100 - remainingTimePercentage);

      String resultMessage;
      Color resultColor;

      if (kValue < 0.4) {
        resultColor = const Color.fromARGB(255, 209, 158, 192);
        resultMessage = AppLocalizations.of(context).translate('gHard');
      } else if (kValue >= 0.4 && kValue < 0.8) {
        resultColor = const Color.fromARGB(255, 179, 141, 166);
        resultMessage = AppLocalizations.of(context).translate('gChal');
      } else if (kValue >= 0.8 && kValue <= 1.2) {
        resultColor = const Color.fromARGB(255, 135, 207, 136);
        resultMessage = AppLocalizations.of(context).translate('gModer');
      } else if (kValue > 1.2 && kValue <= 1.6) {
        resultColor = const Color.fromARGB(255, 131, 172, 206);
        resultMessage = AppLocalizations.of(context).translate('gQEasy');
      } else {
        resultColor = const Color.fromARGB(255, 81, 140, 189);
        resultMessage = AppLocalizations.of(context).translate('gEasy');
      }

      // อัปเดตสถานะ
      setState(() {
        _backgroundColor = resultColor;
        _message = resultMessage;
      });

      // แสดงผล Popup
      await _showResultPopup();
    } catch (e) {
      setState(() {
        _message = "Invalid input! Please enter a valid percentage.";
        _backgroundColor = Colors.red.shade200;
      });
      await _showResultPopup();
    }
  }

  Future<void> _showResultPopup() async {
    final mediaQuery = MediaQuery.of(context);
    // final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _backgroundColor,
          title: Text(AppLocalizations.of(context).translate('calResult')),
          content: Container(
            color: _backgroundColor,
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Text(
              _message,
              style: TextStyle(fontSize: screenWidth * 0.05),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Popup
              },
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: TextStyle(
                    color: pastel.pastelFont, fontSize: screenWidth * 0.032),
              ),
            ),
          ],
        );
      },
    );
  }

  void _autoCalculate() {
    int inputPercentage = widget.mainJobModel.percentProgress;
    _calculateAndChange(inputPercentage);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).translate('calGF'),
        style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: pastel.pastelFont),
      ),
      backgroundColor: pastel.pastel1,
      content: Container(
        color: pastel.pastel2,
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.008),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context).translate('enterSP'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pastel.pastel2,
          ),
          onPressed: () {
            int inputPercentage = int.tryParse(_inputController.text) ?? 0;
            _calculateAndChange(inputPercentage);
          },
          child: Text(
            AppLocalizations.of(context).translate('cal'),
            style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: pastel.pastelFont),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: pastel.pastel2,
              textStyle: TextStyle(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  color: pastel.pastelFont)),
          onPressed: _autoCalculate,
          child: Text(
            AppLocalizations.of(context).translate('useAT'),
            style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: pastel.pastelFont),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: pastel.pastel2,
              textStyle: TextStyle(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  color: pastel.pastelFont)),
          onPressed: () {
            Navigator.of(context).pop(); // ปิด Popup
          },
          child: Text(
            AppLocalizations.of(context).translate('cancel'),
            style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: pastel.pastelFont),
          ),
        ),
      ],
    );
  }
}
