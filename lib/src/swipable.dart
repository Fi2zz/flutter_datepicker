import 'package:flutter/material.dart';

import './month_view.dart';

DateTime getToday() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime maybeToday(DateTime? value) {
  if (value == null) return getToday();
  return DateTime(value.year, value.month, value.day);
}

typedef MonthData = List<DateTime?>;
typedef MonthGridData = List<DateTime>;

typedef DateItemBuilder = Widget Function(BuildContext context, DateItem item);

MonthGridData generateCalendar(DateTime start, DateTime end) {
  final list = <DateTime>[];
  for (var y = start.year; y <= end.year; y++) {
    final mStart = y == start.year ? start.month : 1;
    final mEnd = y == end.year ? end.month : 12;
    for (var m = mStart; m <= mEnd; m++) {
      list.add(DateTime(y, m));
    }
  }
  return list;
}

class DateItem {
  final DateTime date;
  final bool selected;
  final bool enabled;

  DateItem({required this.date, required this.selected, required this.enabled});
}

typedef DateTimeEnabled = bool Function(DateTime);

class SwipableMonthController {
  final GlobalKey<_SwipableMonthViewState> _key =
      GlobalKey<_SwipableMonthViewState>();

  get key {
    return _key;
  }

  void slide(int step) {
    if (step != 1 && step != -1) {
      throw Exception('step must be 1 or -1, currently is ${step}');
    }

    if (step == 1) {
      key.currentState?.next();
    }

    if (step == -1) {
      key.currentState?.prev();
    }
  }

  void next() {
    key.currentState?.next();
  }

  void prev() {
    key.currentState?.prev();
  }
}

class SwipableMonthView extends StatefulWidget {
  final DateTime? from;
  final bool? swipable;
  final DateTime? to;
  final DateTime? current;
  final DateTime? selected;
  final DateTimeEnabled? isDateEnabled;

  final void Function(DateTime) onChangeMonth;
  final void Function(DateTime) onSelectDate;
  final DateItemBuilder itemBuilder;
  const SwipableMonthView({
    super.key,
    this.from,
    this.to,
    this.swipable,
    this.selected, // 默认今天
    this.isDateEnabled,
    required this.onChangeMonth,
    required this.onSelectDate,
    required this.itemBuilder,
    this.current,
  });
  @override
  State<SwipableMonthView> createState() => _SwipableMonthViewState();
}

class _SwipableMonthViewState extends State<SwipableMonthView> {
  late final PageController _controller;
  late MonthGridData _grid;
  late DateTime _from;
  late DateTime _to;
  final int _delta = 1;
  int _cursor = -1;
  late DateTime _selected;
  late DateTime _current;
  // swipe right
  _prepend() {
    setState(() {
      _to = _from.copyWith(year: _from.year, month: 12);
      _from = _from.copyWith(year: _from.year - _delta, month: 1);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage(_delta * 12);
    });
  }

  // swipe left
  _append() {
    setState(() {
      _from = _to.copyWith(year: _to.year - _delta, month: 1);
      _to = _to.copyWith(year: _to.year + _delta, month: 12);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage((_delta + 1) * 12);
    });
  }

  _generate() {
    DateTime today = getToday();
    _from = widget.from ?? DateTime(today.year - _delta, 1);
    _to = widget.to ?? DateTime(today.year + _delta, 12);
    _grid = generateCalendar(_from, _to);
    _current = widget.current ?? DateTime(today.year, today.month);
    _selected = maybeToday(widget.selected);
  }

  bool _internalEqual(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  int _internalFindIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => _internalEqual(m, date));
  }

  _regenerate(DateTime current) {
    _from = current.copyWith(year: current.year - _delta, month: 1);
    _to = current.copyWith(year: current.year + _delta, month: 12);
    _grid = generateCalendar(_from, _to);
    _current = current;
    final slideTo = _internalFindIndex(current);
    if (slideTo != -1) _controller.jumpToPage(slideTo);
    _cursor = -1;
  }

  _initController() {
    int initialPage = _internalFindIndex(widget.current!);
    if (initialPage == -1) _internalFindIndex(widget.selected);
    if (initialPage == -1) initialPage = 0;
    _controller = PageController(initialPage: initialPage);
    _controller.addListener(_listener);
  }

  @override
  void initState() {
    super.initState();
    _generate();
    _initController();
    WidgetsBinding.instance.addPostFrameCallback(_triggerChangeOnce);
  }

  _triggerChangeOnce(_) {
    int idx = _controller.initialPage % _grid.length;
    _onIndexChanged(idx);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  _listener() {
    int page = _controller.page!.round();
    if (page != _cursor) {
      int size = _grid.length;
      _cursor = page <= 0 || page == size ? page : -1;
      if (page <= 0) {
        _prepend();
      } else if (page == size) {
        _append();
      }
    }
  }

  next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  prev() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant SwipableMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_current != widget.current && widget.current != null) {
      _regenerate(widget.current!);
    }
  }

  _onDateSelect(date) {
    setState(() {
      _selected = date;
      widget.onSelectDate(date);
    });
  }

  _onIndexChanged(int idx) {
    final m = _monthAt(idx);
    DateTime date = m.copyWith(year: m.year, month: m.month, day: 1);
    _current = m;
    widget.onChangeMonth(date);
  }

  DateTime _monthAt(int virtualIndex) => _grid[virtualIndex % _grid.length];
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      itemCount: null,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: _onIndexChanged,
      itemBuilder: (_, virtualIndex) {
        final month = _monthAt(virtualIndex);
        return MonthView(
          month: month.month,
          year: month.year,
          value: _selected,
          itemBuilder: widget.itemBuilder,
          isDateEnabled: widget.isDateEnabled,
          onTapDate: _onDateSelect,
        );
      },
    );
  }
}
