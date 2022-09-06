import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static const String DATE_FORMAT = "yyyy-MM-dd";
  static const String TIME_FORMAT = "HH:mm:ss";

  static String getDateFormatted(DateTime date) {
    return DateFormat(DATE_FORMAT).format(date);
  }

  static DateTime getDateTime(String formattedDateTime) {
    int year = int.parse(formattedDateTime.split("-")[0]);
    int month = int.parse(formattedDateTime.split("-")[1]);
    int day = int.parse(formattedDateTime.split("-")[2]);
    int hour = int.parse(formattedDateTime.split(":")[0]);
    int minute = int.parse(formattedDateTime.split(":")[1]);
    int second = int.parse(formattedDateTime.split(":")[2]);
    return new DateTime(year, month, day, hour, minute, second);
  }


  static String formatDate(DateTime date) {
    return DateFormat(DATE_FORMAT).format(date);
  }

  static TimeOfDay timeOfDayParser(String hms) {
    return TimeOfDay(
        hour: int.parse(hms.split(":")[0]),
        minute: int.parse(hms.split(":")[1]));
  }

  static TimeOfDay timeOfDayNow() {
    DateTime now = DateTime.now();
    return new TimeOfDay(hour: now.hour, minute: now.minute);
  }

  static TimeOfDay roundCeil30Minutes(TimeOfDay tod) {
    int hour = tod.hour;
    int minute = tod.minute;
    if (minute > 0 && minute < 30)
      return tod.replacing(minute: 30);
    else if (minute > 30)
      return tod.replacing(hour: hour + 1, minute: 00);
    else
      return tod;
  }

  static String TODToStringHM(TimeOfDay timeOfDay) {
    String hour = timeOfDay.hour >= 10
        ? timeOfDay.hour.toString()
        : "0" + timeOfDay.hour.toString();
    String minute = timeOfDay.minute >= 10
        ? timeOfDay.minute.toString()
        : "0" + timeOfDay.minute.toString();
    return "$hour:$minute";
  }

  static String TODToStringHMS(TimeOfDay timeOfDay) {
    String hour = timeOfDay.hour >= 10
        ? timeOfDay.hour.toString()
        : "0" + timeOfDay.hour.toString();
    String minute = timeOfDay.minute >= 10
        ? timeOfDay.minute.toString()
        : "0" + timeOfDay.minute.toString();
    return "$hour:$minute:00";
  }

  static String hmsTohm(String hms) {
    return "${hms.split(":")[0]}:${hms.split(":")[1]}";
  }

  static String hmTohms(String hm) {
    return "$hm:00";
  }

  static TimeOfDay addMinutes(TimeOfDay tod, int adding) {
    int hour = tod.minute + adding >= TimeOfDay.minutesPerHour
        ? (tod.hour + 1)
        : tod.hour;
    int minute = tod.minute + adding >= TimeOfDay.minutesPerHour
        ? (tod.minute + adding - TimeOfDay.minutesPerHour)
        : tod.minute + adding;
    return tod.replacing(hour: hour, minute: minute);
  }

  static int compareToDate(DateTime date1, DateTime date2) {
    if (date1.year < date2.year) {
      return -1;
    } else if (date1.year > date2.year) {
      return 1;
    } else if (date1.month < date2.month) {
      return -1;
    } else if (date1.month > date2.month) {
      return 1;
    } else
      return date1.day - date2.day;
  }

  static int compareToTimeOfDay(TimeOfDay tod1, TimeOfDay tod2) {
    if (tod1.hour < tod2.hour) {
      return -1;
    } else if (tod1.hour > tod2.hour) {
      return 1;
    } else
      return tod1.minute - tod2.minute;
  }
}
