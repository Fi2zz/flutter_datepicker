import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/src/types/typedefs.dart';
import 'package:flutter_datepicker/src/utils/helpers.dart';

/// Swipable view controller
///
/// Used to control month view sliding
class SwipableViewController {
  _SwipableViewState? _state;

  /// Slide to next month
  void next() {
    _state?.next();
  }

  /// Slide to previous month
  void prev() {
    _state?.prev();
  }

  /// Slide to specified step
  ///
  /// - [step]: Slide step, 1 for next month, -1 for previous month
  void slide(int step) {
    if (step != 1 && step != -1) {
      throw Exception('step must be 1 or -1, currently is $step');
    }
    if (step == 1) {
      next();
    } else {
      prev();
    }
  }

  /// Internal method: attach state
  // ignore: library_private_types_in_public_api
  void attach(_SwipableViewState state) {
    _state = state;
  }

  /// Internal method: detach state
  void dispose() {
    _state = null;
  }
}

/// Grid data type definition
///
/// Represents a list of all months in the calendar
typedef GridData = List<DateTime>;

/// Swipable view widget
///
/// Supports left/right sliding to switch months with infinite scrolling
class SwipableView extends StatefulWidget {
  /// Optional start date of date range
  final DateTime? from;

  final SwipableViewController? controller;

  /// Optional end date of date range
  final DateTime? to;

  /// Currently displayed month
  final DateTime? current;

  /// Month change callback
  final void Function(DateTime) onChangeMonth;

  final SwipableViewBuilder builder;

  /// Create swipable month view
  ///
  /// - [from]: Optional start of date range
  /// - [to]: Optional end of date range
  /// - [onChangeMonth]: Month change callback
  /// - [current]: Currently displayed month
  const SwipableView({
    super.key,
    this.from,
    this.to,
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
  late GridData _grid;

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

  /// Find index of specified date in grid
  int _internalFindIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => isSameMonth(m, date));
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
    widget.controller?.dispose();
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
      oldWidget.controller?.dispose();
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
