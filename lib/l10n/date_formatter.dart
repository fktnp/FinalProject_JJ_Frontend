import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class LocalizedDateFormatter {
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    // สร้าง pattern ตามที่ต้องการ
    return DateFormat('EEEE d MMMM y', locale).format(date);
  }

  static String formatMonth(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    // สร้าง pattern ตามที่ต้องการ
    return DateFormat('MMMM', locale).format(date);
  }
  static String formatYear(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    // สร้าง pattern ตามที่ต้องการ
    return DateFormat('yyyy', locale).format(date);
  }

  static String formatShortDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EEE d MMM y', locale).format(date);
  }

  static String formatShortMonth(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('MMM', locale).format(date);
  }

  static String formatShortDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EEE', locale).format(date);
  }

  static String formatTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('HH:mm', locale).format(date);
  }
}
