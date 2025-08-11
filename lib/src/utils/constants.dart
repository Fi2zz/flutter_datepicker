import 'package:flutter/widgets.dart';

/// 工具类，提供日期选择器所需的常量、样式和辅助函数
///
/// 包含尺寸常量、颜色定义、样式生成和日期计算等功能
class Helpers {
  /// 基础节点高度（用于日历项）
  static const double baseNodeHeight = 40;

  /// 头部高度
  static const double headerHeight = 40;

  /// 星期栏高度
  static const double weekHeight = 40;

  /// 月份视图高度
  static const double monthHeight = 240;

  /// 通用内边距
  static const double padding = 16;

  /// 水平内边距
  static const double horizontalPadding = 12;

  /// 垂直内边距
  static const double verticalPadding = 16;

  /// 最大宽度（日期选择器总宽度）
  static const double maxWidth = 280;

  /// 计算总高度
  ///
  /// 总高度 = 月份视图高度 + 头部高度 + 星期栏高度
  static get maxHeight {
    return monthHeight + headerHeight + weekHeight;
  }

  /// 透明色
  static Color transparent = Color(0x00000000);

  /// 黑色
  static Color black = Color(0xFF000000);

  /// 白色
  static Color white = Color(0xFFFFFFFF);

  /// 文本蓝色（选中状态）
  static Color textBlue = Color(0xFF007AFF);

  /// 浅灰背景色
  static Color lightBackgroundGray = Color(0xFFE5E5EA);

  /// 蓝色（选中背景色，带透明度）
  static Color blue = Color(0x60007AFF);

  /// 文本黑色
  static Color textBlack = Color(0xFF171717);

  /// 文本禁用色（灰色）
  static Color textDisabled = Color(0xFF9E9E9E);

  /// 获取星期文本颜色
  static Color getWeekDayTextColor() {
    return textDisabled;
  }

  /// 生成日期项的装饰
  ///
  /// - [selected]: 是否为选中状态
  static BoxDecoration dayDecoration(bool selected) {
    return BoxDecoration(
      color: Helpers.getDayBackgroundColor(selected),
      borderRadius: BorderRadius.all(Radius.circular(100)),
    );
  }

  /// 生成日期项的文本样式
  ///
  /// - [selected]: 是否为选中状态
  static TextStyle dayTextStyle(bool selected) {
    return TextStyle(
      color: selected ? Helpers.textBlue : Helpers.textBlack,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
  }

  /// 获取日期项的背景色
  ///
  /// - [selected]: 是否为选中状态
  static Color getDayBackgroundColor(bool selected) {
    return selected ? Helpers.blue : Helpers.transparent;
  }

  /// 获取日期项的文本颜色
  ///
  /// - [selected]: 是否为选中状态
  /// - [enabled]: 是否为可用状态
  static Color getDayTextColor(bool selected, bool enabled) {
    if (selected) return Helpers.textBlue;
    if (enabled) return Helpers.textBlack;
    return Helpers.textDisabled;
  }

  /// 年份选择器高度
  static double get yearPickerHeight {
    return monthHeight + weekHeight;
  }

  /// 年份选择器的变换矩阵
  static Matrix4 get yearPickerTransform {
    return Matrix4.translationValues(0, Helpers.headerHeight, 0);
  }

  /// 生成月份矩阵
  ///
  /// 根据指定年月生成日历矩阵，包含空位填充
  /// - [year]: 年份
  /// - [month]: 月份（1-12）
  /// 返回二维列表，每行7天（一周）
  static List<List<DateTime?>> generateMonthMatrix(int year, int month) {
    final first = DateTime(year, month, 1).weekday % 7;
    int days = DateTime(year, month + 1, 0).day;

    final list = <DateTime?>[];
    // 头部占位（月初前的空位）
    for (int i = 0; i < first; i++) {
      list.add(null);
    }
    // 日期
    for (int i = 1; i <= days; i++) {
      list.add(DateTime(year, month, i));
    }
    // 尾部占位（确保完整的周）
    while (list.length % 7 != 0) {
      list.add(null);
    }
    // 转成二维数组
    return List.generate(
      list.length ~/ 7,
      (index) => list.sublist(index * 7, index * 7 + 7),
    );
  }

  /// 私有构造函数，防止实例化
  Helpers._();
}
