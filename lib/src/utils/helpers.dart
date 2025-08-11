/// Get today's date (without time)
DateTime getToday() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Get specified date, return today if null
///
/// - [value]: Input date, can be null
DateTime maybeToday(DateTime? value) {
  if (value == null) return getToday();
  return DateTime(value.year, value.month, value.day);
}

/// Generate calendar data
///
/// Generate list of all months based on date range
/// - [start]: Start date
/// - [end]: End date
/// Returns list of all months in specified range (1st of each month)
List<DateTime> generateCalendar(DateTime start, DateTime end) {
  final list = <DateTime>[];
  for (var y = start.year; y <= end.year; y++) {
    final mStart = y == start.year ? start.month : 1;
    final mEnd = y == end.year ? end.month : 12;
    for (var m = mStart; m <= mEnd; m++) {
      list.add(DateTime(y, m));
    }
  }
  return list;
}

/// Check if two dates are equal (compare year and month only)
bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

/// Check if two dates are equal (compare day only)
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
