import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/datepicker/datepicker.dart';
// import 'package:flutter_datepicker/datepicker/datepicker.dart';

class YearView extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final DateTime selected;

  final ValueChanged<DateTime> onSelect;

  const YearView({
    super.key,
    required this.start,
    required this.end,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<StatefulWidget> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  late DateTime start;
  late DateTime end;
  late int count = 100;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        int year = index + widget.start.year;

        Widget node = Container(
          decoration: BoxDecoration(color: Color(0xFFFF0000)),
          height: baseItemHeight,
          child: Center(
            child: Text(
              (year).toString(),
              style: TextStyle(color: Color(0xFF000000)),
            ),
          ),
        );

        return GestureDetector(
          child: node,
          onTap: () => widget.onSelect(DateTime(year)),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    count = widget.end.year - widget.start.year + 1;
  }
}
