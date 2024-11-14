import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'l10n/date_formatter.dart';
import 'providers/locale_provider.dart';

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('welcome')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.translate('hello')),
            // แยก Button ออกมาเป็น Widget ต่างหาก
            const LanguageToggleButton(),
            DateDisplay(
              date: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }
}

// แยก Button ออกมาเป็น Widget แยก
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        final currentLocale = provider.locale.languageCode;
        print('Current locale in button: $currentLocale'); // Debug print

        return ElevatedButton(
          onPressed: () async {
            try {
              final newLocale = currentLocale == 'th'
                  ? const Locale('en')
                  : const Locale('th');
              print(
                  'Changing locale from $currentLocale to ${newLocale.languageCode}'); // Debug print
              await provider.setLocale(newLocale);
            } catch (e) {
              print('Error changing locale: $e'); // Debug print
            }
          },
          child:
              Text(AppLocalizations.of(context).translate('change_language')),
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
        Text(LocalizedDateFormatter.formatDate(context, date)),
        // รูปแบบสั้น
        Text(LocalizedDateFormatter.formatShortDate(context, date)),
        // เวลา
        Text(LocalizedDateFormatter.formatTime(context, date)),
      ],
    );
  }
}
