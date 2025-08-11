import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import '../types/typedefs.dart';
import '../controllers/swipable_controller.dart';

/// Month data type definition
/// 
/// Represents all dates for a single month, including empty placeholders
typedef MonthData = List<DateTime?>;

/// Month grid data type definition
/// 
/// Represents a list of all months in the calendar
typedef MonthGridData = List<DateTime>;

/// Get today's date (without time)
DateTime getToday() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Get specified date, return today if null
/// 
/// - [value]: Input date, can be null
DateTime maybeToday(DateTime? value) {
  if (value == null) return getToday();
  return DateTime(value.year, value.month, value.day);
}

/// Generate calendar data
/// 
/// Generate list of all months based on date range
/// - [start]: Start date
/// - [end]: End date
/// Returns list of all months in specified range (1st of each month)
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

/// Swipable view widget
/// 
/// Supports left/right sliding to switch months with infinite scrolling
class SwipableView extends StatefulWidget {
  /// Optional start date of date range
  final DateTime? from;

  final SwipableViewController? controller;

  /// Whether swipable (reserved parameter, currently unused)
  final bool? swipable;

  /// Optional end date of date range
  final DateTime? to;

  /// Currently displayed month
  final DateTime? current;

  /// Function to determine if date is available
  final DateTimeEnabled? isDateEnabled;

  /// Month change callback
  final void Function(DateTime) onChangeMonth;

  final SwipableViewBuilder builder;

  /// Create swipable month view
  /// 
  /// - [from]: Optional start of date range
  /// - [to]: Optional end of date range
  /// - [swipable]: Whether swipable (reserved)
  /// - [isDateEnabled]: Function to determine if date is available
  /// - [onChangeMonth]: Month change callback
  /// - [current]: Currently displayed month
  const SwipableView({
    super.key,
    this.from,
    this.to,
    this.swipable,
    this.isDateEnabled,
    required this.onChangeMonth,
    required this.builder,
    this.current,
    this.controller,
  });
  @override
  State<SwipableView> createState() => _SwipableViewState();
}

class _SwipableViewState extends State<SwipableView> {
  /// Page controller for managing month sliding
  late final PageController _controller;

  /// Month grid data
  late MonthGridData _grid;

  /// Optional start date of date range
  late DateTime _from;

  /// Optional end date of date range
  late DateTime _to;

  /// Sliding range increment (in years)
  final int _delta = 1;

  /// Current page cursor
  int _cursor = -1;

  /// Currently displayed month
  late DateTime _current;

  /// Prepend data (when swiping right)
  /// 
  /// Automatically prepend earlier month data when user swipes right to boundary
  _prepend() {
    setState(() {
      _to = _from.copyWith(year: _from.year, month: 12);
      _from = _from.copyWith(year: _from.year - _delta, month: 1);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage(_delta * 12);
    });
  }

  /// Append data (when swiping left)
  /// 
  /// Automatically append later month data when user swipes left to boundary
  _append() {
    setState(() {
      _from = _to.copyWith(year: _to.year - _delta, month: 1);
      _to = _to.copyWith(year: _to.year + _delta, month: 12);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage((_delta + 1) * 12);
    });
  }

  /// Initialize data
  /// 
  /// Initialize date range, current month, and selected date based on input parameters
  _generate() {
    DateTime today = getToday();
    _from = widget.from ?? DateTime(today.year - _delta, 1);
    _to = widget.to ?? DateTime(today.year + _delta, 12);
    _grid = generateCalendar(_from, _to);
    _current = widget.current ?? DateTime(today.year, today.month);
  }

  /// Check if two dates are equal (compare year and month only)
  bool _internalEqual(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Find index of specified date in grid
  int _internalFindIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => _internalEqual(m, date));
  }

  /// Regenerate data
  /// 
  /// Recalculate date range when external current changes
  _regenerate(DateTime current) {
    _from = current.copyWith(year: current.year - _delta, month: 1);
    _to = current.copyWith(year: current.year + _delta, month: 12);
    _grid = generateCalendar(_from, _to);
    _current = current;
    final slideTo = _internalFindIndex(current);
    if (slideTo != -1) _controller.jumpToPage(slideTo);
    _cursor = -1;
  }

  /// Initialize page controller
  _initController() {
    int initialPage = _internalFindIndex(widget.current!);
    if (initialPage == -1) initialPage = 0;
    _controller = PageController(initialPage: initialPage);
    _controller.addListener(_listener);
  }

  @override
  void initState() {
    super.initState();
    _generate();
    _initController();
    widget.controller?.attach(this);
    WidgetsBinding.instance.addPostFrameCallback(_triggerChangeOnce);
  }

  /// Trigger change callback once
  /// 
  /// Ensure month change callback is triggered on initial display
  _triggerChangeOnce(_) {
    int idx = _controller.initialPage % _grid.length;
    _onIndexChanged(idx);
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  /// Page sliding listener
  /// 
  /// Handle data appending logic on boundary sliding
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

  /// Slide to next month
  next() {
    if (_controller.hasClients) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Slide to previous month
  prev() {
    if (_controller.hasClients) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(covariant SwipableView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
    }
    if (_current != widget.current && widget.current != null) {
      _regenerate(widget.current!);
    }
  }

  /// Month index change handling
  /// 
  /// Trigger callback when sliding to new month
  _onIndexChanged(int idx) {
    final m = _monthAt(idx);
    DateTime date = m.copyWith(year: m.year, month: m.month, day: 1);
    _current = m;
    widget.onChangeMonth(date);
  }

  /// Get month at specified index
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
        final item = _monthAt(virtualIndex);
        return widget.builder(context, item);
      },
    );
  }
}