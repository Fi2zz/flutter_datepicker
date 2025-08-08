import 'package:flutter/material.dart';
import 'package:flutter_datepicker/src/year_view.dart';
import './helpers.dart';
import './swipable.dart';
import 'week_view.dart';
import './widgets.dart';

typedef TitleBuilder =
    List<Widget> Function(
      BuildContext context,
      DateTime date,
      bool highlighted,
    );

class DatePicker extends StatefulWidget {
  final DateTime? value;
  final DateTime? from, to;
  final DateTimeEnabled? isDateEnabled;
  final void Function(DateTime)? onChanged;
  final DateItemBuilder? dateItemBuilder;
  final TitleBuilder? titleBuilder;
  final int? headerLayout; // = headerLayoutTitleLeftRight;
  const DatePicker({
    super.key,
    this.value,
    this.from,
    this.to,
    this.isDateEnabled,
    this.onChanged,
    this.titleBuilder,
    this.dateItemBuilder,
    headerLayout,
  }) : headerLayout = headerLayout ?? DatePicker.headerLayoutTitleLeftRight;
  @override
  State<DatePicker> createState() => _DatePickerState();
  static const firstDayofweek = 1;

  /// Aug 2025 >  ◄ ►
  static const headerLayoutTitleLeftRight = 1;

  /// ◄  Aug 2025   ►
  static const headerLayoutLeftTitleRight = 2;
}

class _DatePickerState extends State<DatePicker> {
  late final DateTime? _from = widget.from;
  late final DateTime? _to = widget.to;
  late DateTime _display = widget.value!; // 当前正在展示的月份（1 号）
  final List<String> weekData = List.from('日一二三四五六'.split(''));
  final SwipableMonthController _controller = SwipableMonthController();
  bool _showYearsView = false;
  _onSelectYear(int year) => setState(() {
    _showYearsView = false;
    _display = DateTime(year, _display.month);
  });
  bool _isMonthEnabled(step, date) {
    //  next month
    if (step == 1) {
      if (widget.to == null) return true;
      return !date.isAfter(DateTime(widget.to!.year, widget.to!.month));
    }
    if (step == -1) {
      if (widget.from == null) return true;
      return !date.isBefore(DateTime(widget.from!.year, widget.from!.month));
    }
    return true;
  }

  Widget _buildYearView() {
    return Container(
      color: Helpers.white,
      width: Helpers.maxWidth,
      height: Helpers.yearPickerHeight,
      child: YearsView(
        itemBuilder: _yearBuilder,
        onSelect: _onSelectYear,
        to: _to?.year,
        from: _from?.year,
        value: _display.year,
      ),
    );
  }

  Widget _yearBuilder(BuildContext context, int year, bool selected) {
    Widget node = Center(
      child: Text(
        (year).toString(),
        style: TextStyle(
          color: selected ? Helpers.textBlue : Helpers.textBlack,
        ),
      ),
    );
    return node;
  }

  _titleBuilder(
    BuildContext context,
    DateTime date,
    bool active,
    bool showChevron,
  ) {
    if (widget.titleBuilder != null) {
      return widget.titleBuilder!(context, date, active);
    }
    Widget text = Text(
      '${date.year}年 ${date.month}月',
      style: TextStyle(
        color: active ? Helpers.textBlue : Helpers.black,
        fontWeight: FontWeight.bold,
      ),
    );

    if (!showChevron) return [text];
    return [text, RotatableCheronRight(size: 16, active: _showYearsView)];
  }

  Widget _buildTitleView(bool showChevron) {
    // bool showChevron =
    //     widget.headerLayout != DatePicker.headerLayoutLeftTitleRight;
    List<Widget> title = _titleBuilder(
      context,
      _display,
      _showYearsView,
      showChevron,
    );
    return Tappable(
      onTap: () {
        setState(() => _showYearsView = !_showYearsView);
      },
      tappable: true,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: title,
        ),
      ),
    );
  }

  Widget _buildHeaderView() {
    Widget title = _buildTitleView(
      widget.headerLayout != DatePicker.headerLayoutLeftTitleRight,
    );
    bool visible = !_showYearsView;
    Widget left = FadeInOut(
      visible: visible,
      child: Chevron(
        type: 'left',
        touchable: _isMonthEnabled(-1, _display) && !_showYearsView,
        onTap: () => _controller.slide(-1),
      ),
    );
    Widget right = FadeInOut(
      visible: visible,
      child: Chevron(
        type: 'right',
        touchable: _isMonthEnabled(1, _display) && !_showYearsView,
        onTap: () => _controller.slide(1),
      ),
    );

    List<Widget> children = [];
    if (widget.headerLayout == DatePicker.headerLayoutLeftTitleRight) {
      children = [left, title, right];
    }
    if (widget.headerLayout == DatePicker.headerLayoutTitleLeftRight) {
      children = [
        title,
        Row(children: [left, right]),
      ];
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget children = Stack(
      children: [
        Opacity(
          opacity: _showYearsView ? 0.0 : 1.0,

          child: Column(
            children: [
              SizedBox(
                width: Helpers.maxWidth,
                height: Helpers.baseNodeHeight,
                child: _buildHeaderView(),
              ),
              SizedBox(
                width: Helpers.maxWidth,
                height: Helpers.baseNodeHeight,
                child: WeekView(data: weekData),
              ),
              SizedBox(
                width: Helpers.maxWidth,
                height: Helpers.monthHeight,
                child: SwipableMonthView(
                  key: _controller.key,
                  from: _from,
                  to: _to,
                  current: _display,
                  selected: widget.value,
                  onSelectDate: widget.onChanged!,
                  onChangeMonth: (date) => setState(() => _display = date),
                  itemBuilder: widget.dateItemBuilder!,
                  isDateEnabled: widget.isDateEnabled,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: FadeInOut(
            visible: _showYearsView,
            child: Column(
              children: [
                _showYearsView ? _buildTitleView(false) : Container(),
                _buildYearView(),
              ],
            ),
          ),
        ),
      ],
    );
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: Helpers.horizontalPadding,
        horizontal: Helpers.horizontalPadding,
      ),
      child: SizedBox(
        width: Helpers.maxWidth,
        height: Helpers.maxHeight,
        child: children,
      ),
    );
  }
}
