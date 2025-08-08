import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './datepicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(title: 'Flutter Demo', home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DateTime _date = DateTime.now(); //(2025, 1, 2);
  void onDateSelected(value) {
    setState(() => _date = value);
  }

  // @override
  // void initState() {
  //   _date = DateTime(2025, 7, 7);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    Widget datepicker = DatePicker(
      value: _date.copyWith(),
      // from: DateTime(2010),
      // to: DateTime(2030),
      isDateEnabled: (date) => date != DateTime(2025, 8, 7),
      onChanged: onDateSelected,
      // headerLayout: DatePicker.headerLayoutLeftTitleRight,

      dateItemBuilder: (context, item) {
        return Text(
          item.date.day.toString(),
          style: TextStyle(color: Color(0xFF202020)),
        );
      },
    );

    return CupertinoPageScaffold(
      backgroundColor: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
            child: datepicker,
          ),

          Text(
            _date.toLocal().toString(),
            style: TextStyle(color: Color(0xffff0000)),
          ),
        ],
      ),
    );
  }
}
