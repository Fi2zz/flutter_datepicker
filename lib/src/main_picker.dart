import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'l10n/datepicker_localizations.dart';
import 'utils/helpers.dart';
import 'views/swipable_view.dart';
import 'views/month_view.dart';
import 'views/week_view.dart';
import 'views/year_view.dart';
import 'widgets/common_widgets.dart';
import 'utils/constants.dart';
import 'types/typedefs.dart';

enum DatePickerHeaderLayout {
  /// Aug 2025 >  ◄ ►
  /// Title - Left - Right
  // ignore: constant_identifier_names
  HTLR,

  /// ◄  Aug 2025   ►
  /// Left - Title - Right
  // ignore: constant_identifier_names
  HLTR,
}

/// 日期选择器组件
///
/// 一个功能完整的日期选择器，支持月份切换、年份选择、日期禁用等功能
/// 提供多种布局方式和自定义构建选项
class DatePicker extends StatefulWidget {
  final DateTime? value;
  final DateTime? from, to;
  final DateTimeEnabled? isDateEnabled;
  final void Function(DateTime)? onChanged;
  final DateItemBuilder? dateItemBuilder;
  final TitleBuilder? titleBuilder;
  final DatePickerHeaderLayout? headerLayout; // = headerLayoutTitleLeftRight;
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
  }) : headerLayout = headerLayout ?? DatePickerHeaderLayout.HTLR;
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late final DateTime? _from = widget.from;
  late final DateTime? _to = widget.to;

  late DateTime _selected = maybeToday(widget.value);
  late DateTime _display = maybeToday(widget.value); // 当前正在展示的月份（1 号）
  List<String> get weekData {
    final locale = Localizations.localeOf(context);
    final localizations = DatePickerLocalizations(locale);
    return localizations.weekdayNames;
  }

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
    return Center(
      child: Text(
        year.toString(),
        style: TextStyle(
          color: selected ? Helpers.textBlue : Helpers.textBlack,
        ),
      ),
    );
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

    final locale = Localizations.localeOf(context);
    final localizations = DatePickerLocalizations.of(context);
    final formatString = localizations?.monthYearFormat ?? 'yyyy年M月';
    final formatter = DateFormat(formatString, locale.toString());
    final text = formatter.format(date);

    Widget textWidget = Text(
      text,
      style: TextStyle(
        color: active ? Helpers.textBlue : Helpers.black,
        fontWeight: FontWeight.bold,
      ),
    );

    if (!showChevron) return [textWidget];
    return [textWidget, RotatableCheronRight(size: 16, active: _showYearsView)];
  }

  Widget _buildTitleView(bool showChevron) {
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
      widget.headerLayout != DatePickerHeaderLayout.HLTR,
    );
    bool visible = !_showYearsView;
    Widget left = FadeInOut(
      visible: visible,
      child: Chevron(
        type: 'left',
        touchable: _isMonthEnabled(-1, _display) && !_showYearsView,
        onTap: () => controller.prev(),
      ),
    );
    Widget right = FadeInOut(
      visible: visible,
      child: Chevron(
        type: 'right',
        touchable: _isMonthEnabled(1, _display) && !_showYearsView,
        onTap: () => controller.next(),
      ),
    );

    List<Widget> children = [];
    if (widget.headerLayout == DatePickerHeaderLayout.HLTR) {
      children = [left, title, right];
    }
    if (widget.headerLayout == DatePickerHeaderLayout.HTLR) {
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

  /// 日期选择处理
  _onDateSelect(date) {
    setState(() {
      _selected = date;
      widget.onChanged!(date);
    });
  }

  SwipableViewController controller = SwipableViewController();

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
                child: SwipableView(
                  controller: controller,
                  from: _from,
                  to: _to,
                  current: _display,
                  onChangeMonth: (date) => setState(() => _display = date),
                  builder: (BuildContext context, DateTime item) {
                    return MonthView(
                      month: item.month,
                      year: item.year,
                      value: _selected,
                      itemBuilder: widget.dateItemBuilder,
                      isDateEnabled: widget.isDateEnabled,
                      onTapDate: _onDateSelect,
                    );
                  },
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
