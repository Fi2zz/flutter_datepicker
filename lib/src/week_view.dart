import 'package:flutter/widgets.dart';
import './helpers.dart';

class WeekView extends StatelessWidget {
  final List<String> data;
  const WeekView({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: [
        for (final date in data)
          Center(
            child: Text(
              date,
              style: TextStyle(color: Helpers.getWeekDayTextColor()),
            ),
          ),
      ],
    );
  }
}
