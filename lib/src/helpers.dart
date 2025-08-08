import 'package:flutter/widgets.dart';

class Helpers {
  static const double baseNodeHeight = 40;
  static const double headerHeight = 40;
  static const double weekHeight = 40;
  static const double monthHeight = 240;
  static const double padding = 16;
  static const double horizontalPadding = 12;
  static const double verticalPadding = 16;
  static const double maxWidth = 280;
  static get maxHeight {
    return monthHeight + headerHeight + weekHeight;
  }

  static Color transparent = Color(0x00000000);
  static Color black = Color(0xFF000000);
  static Color white = Color(0xFFFFFFFF);
  static Color textBlue = Color(0xFF007AFF);
  static Color lightBackgroundGray = Color(0xFFE5E5EA);

  static Color blue = Color(0x60007AFF);

  static Color textBlack = Color(0xFF171717);
  static Color textDisabled = Color(0xFF9E9E9E);
  static Color getWeekDayTextColor() {
    return textDisabled;
  }

  static BoxDecoration dayDecoration(bool selected) {
    return BoxDecoration(
      color: Helpers.getDayBackgroundColor(selected),
      borderRadius: BorderRadius.all(Radius.circular(100)),
    );
  }

  static TextStyle dayTextStyle(bool selected) {
    return TextStyle(
      color: selected ? Helpers.textBlue : Helpers.textBlack,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
  }

  static Color getDayBackgroundColor(bool selected) {
    return selected ? Helpers.blue : Helpers.transparent;
  }

  static Color getDayTextColor(bool selected, bool enabled) {
    if (selected) return Helpers.textBlue;
    if (enabled) return Helpers.textBlack;
    return Helpers.textDisabled;
  }

  static double get yearPickerHeight {
    return monthHeight + weekHeight;
  }

  static Matrix4 get yearPickerTransform {
    return Matrix4.translationValues(0, Helpers.headerHeight, 0);
  }

  static List<List<DateTime?>> generateMonthMatrix(int year, int month) {
    final first = DateTime(year, month, 1).weekday % 7;
    int days = DateTime(year, month + 1, 0).day;

    // final totalDays = days += 1;
    final list = <DateTime?>[];
    // 头部占位
    for (int i = 0; i < first; i++) {
      list.add(null);
    }
    // 日期
    for (int i = 1; i <= days; i++) {
      list.add(DateTime(year, month, i));
    }
    while (list.length % 7 != 0) {
      list.add(null);
    }
    // 转成二维
    return List.generate(
      list.length ~/ 7,
      (index) => list.sublist(index * 7, index * 7 + 7),
    );
  }

  // 不允许实例化
  Helpers._();
}
