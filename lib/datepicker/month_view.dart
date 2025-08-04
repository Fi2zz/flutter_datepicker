import 'package:flutter_datepicker/datepicker/datepicker.dart';
import 'package:flutter/widgets.dart';

class MonthView extends StatelessWidget {
  final int year, month;
  final DateTime? selected;
  final ValueChanged<DateTime> onDaySelected;
  final bool Function(DateTime)? isEnabled;

  final BoxConstraints itemConstriant;

  const MonthView({
    super.key,

    required this.year,
    required this.month,
    this.selected,
    required this.onDaySelected,
    this.isEnabled,
    required this.itemConstriant,
  });

  _onSelected(day) {
    if (isEnabled == null || isEnabled!(day)) {
      onDaySelected(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = CalendarLogic.monthMatrix(year, month);
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: [
        for (final week in matrix)
          for (final day in week)
            if (day == null)
              const SizedBox.shrink()
            else
              GestureDetector(
                onTap: () => _onSelected(day),
                child: ConstrainedBox(
                  constraints: itemConstriant,
                  child: Container(
                    decoration: BoxDecoration(
                      color: day == selected ? activeBlue : fullTransparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                        // BorderRadius
                      ),
                    ),

                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: day == selected
                              ? fullWhite
                              : (isEnabled == null || isEnabled!(day))
                              ? textBlack
                              : textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
