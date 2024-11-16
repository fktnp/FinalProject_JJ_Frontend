import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'l10n/date_formatter.dart';
import 'model/theme.dart';
import 'providers/locale_provider.dart';

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      backgroundColor: pastel.pastel2,
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Text(
          overflow: TextOverflow.ellipsis,
          localizations.translate('language'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const LanguageToggleButton(),
    );
  }
}

// แยก Button ออกมาเป็น Widget แยก
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        final currentLocale = provider.locale.languageCode;

        return Container(
          margin: EdgeInsets.only(
              top: screenHeight * 0.02,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // กล่องสำหรับภาษาอังกฤษ
              GestureDetector(
                onTap: () async {
                  if (currentLocale != 'en') {
                    await provider.setLocale(const Locale('en'));
                  }
                },
                child: Container(
                  width: screenWidth * 0.33,
                  height: screenHeight * 0.07,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: currentLocale == 'en'
                        ? pastel.pastel1
                        : Colors.grey[300], // เปลี่ยนสีตามสถานะ
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    'English',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentLocale == 'en'
                          ? pastel.pastelFont
                          : pastel.pastelFont2,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // กล่องสำหรับภาษาไทย
              GestureDetector(
                onTap: () async {
                  if (currentLocale != 'th') {
                    await provider.setLocale(const Locale('th'));
                  }
                },
                child: Container(
                  width: screenWidth * 0.33,
                  height: screenHeight * 0.07,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: currentLocale == 'th'
                        ? pastel.pastel1
                        : Colors.grey[300], // เปลี่ยนสีตามสถานะ
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    'ภาษาไทย',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentLocale == 'th'
                          ? pastel.pastelFont
                          : pastel.pastelFont2,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DateDisplay extends StatelessWidget {
  final DateTime date;

  const DateDisplay({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // วันที่เต็มรูปแบบ
        Text(
            overflow: TextOverflow.ellipsis,
            LocalizedDateFormatter.formatDate(context, date)),
        // รูปแบบสั้น
        Text(
            overflow: TextOverflow.ellipsis,
            LocalizedDateFormatter.formatShortDate(context, date)),
        // เวลา
        Text(
            overflow: TextOverflow.ellipsis,
            LocalizedDateFormatter.formatTime(context, date)),
      ],
    );
  }
}
