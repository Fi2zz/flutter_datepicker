import 'package:flutter/material.dart';
import './widgets.dart';
import 'swipable_view.dart';

import './helpers.dart';

/// 生成日期项的装饰样式
/// 
/// - [selected]: 是否为选中状态
/// - [enabled]: 是否为可用状态
BoxDecoration decoration(bool selected, enabled) {
  return BoxDecoration(
    color: Helpers.getDayBackgroundColor(selected),
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );
}

/// 生成日期项的文本样式
/// 
/// - [selected]: 是否为选中状态
/// - [enabled]: 是否为可用状态
TextStyle textStyle(bool selected, enabled) {
  return TextStyle(
    color: !enabled
        ? Helpers.textDisabled
        : selected
        ? Helpers.textBlue
        : Helpers.textBlack,
    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
  );
}

/// 月份视图组件
/// 
/// 显示单个月份的日历网格，包含所有日期和空位填充
class MonthView extends StatelessWidget {
  /// 当前选中的日期
  final DateTime value;
  
  /// 年份
  final int year;
  
  /// 月份（1-12）
  final int month;
  
  /// 日期是否可用的判断函数
  final DateTimeEnabled? isDateEnabled;
  
  /// 自定义日期项构建器
  final DateItemBuilder? itemBuilder;
  
  /// 日期点击回调
  final void Function(DateTime)? onTapDate;
  
  /// 创建月份视图
  /// 
  /// - [year]: 年份
  /// - [month]: 月份（1-12）
  /// - [value]: 当前选中的日期
  /// - [itemBuilder]: 自定义日期项构建器
  /// - [isDateEnabled]: 判断日期是否可用
  /// - [onTapDate]: 日期点击回调
  const MonthView({
    super.key,
    required this.month,
    required this.year,
    required this.value,
    this.itemBuilder,
    this.isDateEnabled,
    this.onTapDate,
  });

  _generateMonth(DateTime month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    return List.generate(42, (i) {
      final day = i - firstWeekday + 1;
      return day >= 1 && day <= days
          ? DateTime(month.year, month.month, day)
          : null;
    });
  }

  _isDateEnabled(DateTime date) {
    if (isDateEnabled == null) return true;
    return isDateEnabled!(date);
  }

  _itemBuilder(BuildContext context, DateItem item) {
    if (itemBuilder != null) return Center(child: itemBuilder!(context, item));

    return Container(
      decoration: decoration(item.selected, item.enabled),
      alignment: Alignment.center,
      child: Text(
        item.date.day.toString(),
        style: textStyle(item.selected, item.enabled),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime?> data = _generateMonth(DateTime(year, month));
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final date = data[index];
        if (date == null) return SizedBox.shrink();
        final selected = date == value;
        final child = _itemBuilder(
          context,
          DateItem(
            date: date,
            selected: selected,
            enabled: _isDateEnabled(date),
          ),
        );
        return Tappable(
          tappable: _isDateEnabled(date),
          onTap: () => onTapDate!(date),
          child: child,
        );
      },
    );
  }
}

// typedef P ={

// }
