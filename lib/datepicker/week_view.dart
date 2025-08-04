// import 'package:flutter_datepicker/datepicker/datepicker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/datepicker/datepicker.dart';

class WeekView extends StatelessWidget {
  WeekView({super.key});

  final List list = List.from('日一二三四五六'.split(''));
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: [
        for (final d in list)
          Center(
            child: Text(d, style: TextStyle(color: textDisabled)),
          ),
        //  ,
      ],
    );
  }
}
