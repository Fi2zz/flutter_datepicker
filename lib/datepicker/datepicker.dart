// import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/datepicker/month_header_view.dart';
import 'package:flutter_datepicker/datepicker/month_view.dart';
import 'package:flutter_datepicker/datepicker/week_view.dart';
import 'package:flutter_datepicker/datepicker/year_view.dart';

class CalendarLogic {
  /// 某月第一天是星期几（0=Monday … 6=Sunday）
  static int firstWeekdayOfMonth(int year, int month) =>
      DateTime(year, month, 1).weekday % 7;

  /// 某月一共有几天
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// 生成某月的日历矩阵（6 行 7 列，空白处填 null）
  static List<List<DateTime?>> monthMatrix(int year, int month) {
    final first = firstWeekdayOfMonth(year, month);
    int days = daysInMonth(year, month);

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
    // 尾部占位
    while (list.length % 7 != 0) {
      list.add(null);
    }
    // 转成二维
    return List.generate(
      list.length ~/ 7,
      (index) => list.sublist(index * 7, index * 7 + 7),
    );
  }
}

Color fullTransparent = Color(0x00000000);
Color fullBlack = Color(0xFF000000);
Color fullWhite = Color(0xFFFFFFFF);
Color activeBlue = Color.fromARGB(255, 0, 122, 255);
Color lightBackgroundGray = Color(0xFFE5E5EA);
Color textBlack = Color(0xFF171717);
Color textDisabled = Color.fromARGB(255, 142, 142, 147);

double baseItemHeight = 44;

typedef RenderDate =
    Widget Function(DateTime date, bool isSelected, bool isEnabled);

class DatePicker extends StatefulWidget {
  final DateTime current;
  final DateTime? from, to;
  final ValueChanged<DateTime>? onDateSelected;
  final RenderDate? renderDate;
  DatePicker({
    super.key,
    current,
    this.from,
    this.to,
    this.onDateSelected,
    this.renderDate,
  }) : current = current ?? DateTime.now();

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _display; // 当前正在展示的月份（1 号）
  late DateTime _selected; // 真正被选中的日期

  _onSelectedDate(d) {
    setState(() {
      widget.onDateSelected?.call(d);
      _selected = d;
    });
  }

  _onMonthChanged(date) {
    setState(() {
      _display = date;
    });
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _display = DateTime(widget.current.year, widget.current.month);
    // _showMonthControl = true;
  }

  bool _isEnabled(DateTime d) =>
      (widget.from == null || !d.isBefore(widget.from!)) &&
      (widget.to == null || !d.isAfter(widget.to!));

  bool _showMonthControl = true;

  _onToggleControl(show) {
    setState(() {
      _showMonthControl = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    double maxHeight = 460;
    double maxWidth = 350;
    double minHeight = 320;
    double minWidth = 280;
    double itemMaxWidth = maxWidth / 7;
    double itemMaxHeight = (maxHeight - baseItemHeight) / 6;
    double itemMinWidth = maxWidth / 7;
    double itemMinHeight = (minHeight - baseItemHeight) / 6;

    BoxConstraints constraint = BoxConstraints(
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      // minHeight: minHeight,
      minWidth: minWidth,
    );

    BoxConstraints itemConstriant = BoxConstraints(
      maxWidth: itemMaxWidth,
      maxHeight: itemMaxHeight,
      minWidth: itemMinWidth,
      minHeight: itemMinHeight,
    );

    if (!_showMonthControl) {
      // 假设每个 item 是正方形（宽高比 1:1）
      // 每行高度 = (屏幕宽 / 4) - 间距
      Widget yearView = YearView(
        start: widget.from ?? DateTime(1900),
        end: widget.to ?? DateTime(3000),
        selected: _selected,
        onSelect: _onSelectedDate,
      );
      children = [SizedBox(height: baseItemHeight * 6, child: yearView)];
    } else {
      children = [
        WeekView(),
        MonthView(
          year: _display.year,
          month: _display.month,
          selected: _selected,
          isEnabled: _isEnabled,
          itemConstriant: itemConstriant,
          onDaySelected: (d) => _onSelectedDate(d),
        ),
      ];
    }

    Widget core = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: baseItemHeight,
          child: HeaderView(
            current: _display,
            onToggleControl: _onToggleControl,
            onMonthChange: _onMonthChanged,
            showMonthControl: _showMonthControl,
          ),
        ),
        ...children,
      ],
    );
    return Padding(
      padding: EdgeInsetsGeometry.all(16),
      child: ConstrainedBox(constraints: constraint, child: core),
    );
  }
}
