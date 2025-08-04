import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import './datepicker/datepicker.dart';

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
  DateTime _date = DateTime.now();

  void onDateSelected(d) {
    setState(() {
      _date = d;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget datepicker = DatePicker(
      current: DateTime.now(),
      from: DateTime(1900),
      to: DateTime(2050),
      onDateSelected: onDateSelected,
    );

    return CupertinoPageScaffold(
      backgroundColor: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12),
            // padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fullWhite,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
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
