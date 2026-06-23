import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatIndonesianDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  static String getFormattedClock(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String getTodayIndonesianName(DateTime date) {
    const daysIndo = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return daysIndo[date.weekday % 7];
  }
}
