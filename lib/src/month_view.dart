import 'package:flutter/material.dart';
import './widgets.dart';
import './swipable.dart';

import './helpers.dart';

BoxDecoration decoration(bool selected, enabled) {
  return BoxDecoration(
    color: Helpers.getDayBackgroundColor(selected),
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );
}

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

class MonthView extends StatelessWidget {
  final DateTime value;
  final int year;
  final int month;
  final DateTimeEnabled? isDateEnabled;
  final DateItemBuilder? itemBuilder;
  final void Function(DateTime)? onTapDate;
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
