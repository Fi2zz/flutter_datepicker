import 'package:flutter/material.dart';

/// 获取今天的日期（去除时间部分）
DateTime getToday() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// 获取指定日期，如果为null则返回今天
///
/// - [value]: 输入日期，可以为null
DateTime maybeToday(DateTime? value) {
  if (value == null) return getToday();
  return DateTime(value.year, value.month, value.day);
}

/// 月份数据类型定义
///
/// 表示单个月份的所有日期，包含空位填充r
typedef MonthData = List<DateTime?>;

/// 月份网格数据类型定义
///
/// 表示日历中所有月份的列表
typedef MonthGridData = List<DateTime>;

/// 日期项构建器类型定义
///
/// - [context]: 构建上下文
/// - [item]: 包含日期信息的对象
typedef DateItemBuilder = Widget Function(BuildContext context, DateItem item);

/// 生成日历数据
///
/// 根据日期范围生成所有月份的列表
/// - [start]: 开始日期
/// - [end]: 结束日期
/// 返回指定范围内的所有月份（每月1号）
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

/// 日期项数据类
///
/// 包含日期及其状态的完整信息
class DateItem {
  /// 日期
  final DateTime date;

  /// 是否选中
  final bool selected;

  /// 是否可用
  final bool enabled;

  DateItem({required this.date, required this.selected, required this.enabled});
}

/// 日期可用性判断函数类型定义
///
/// - [DateTime]: 要判断的日期
/// 返回该日期是否可用
typedef DateTimeEnabled = bool Function(DateTime);

/// 可滑动月份控制器
///
/// 用于控制月份视图的滑动切换
class SwipableViewController {
  _SwipableViewState? _state;

  /// 滑动到下一个月
  void next() {
    _state?.next();
  }

  /// 滑动到上一个月
  void prev() {
    _state?.prev();
  }

  /// 滑动到指定步长的月份
  ///
  /// - [step]: 滑动步长，1为下一月，-1为上一月
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

  /// 内部方法：绑定状态
  // ignore: library_private_types_in_public_api
  void attach(_SwipableViewState state) {
    _state = state;
  }

  /// 内部方法：解绑状态
  void detach() {
    _state = null;
  }
}

typedef SwipableViewBuilder =
    Widget Function(BuildContext context, DateTime item);

/// 可滑动月份视图组件
///
/// 支持左右滑动切换月份，支持无限滚动
class SwipableView extends StatefulWidget {
  /// 可选日期范围的开始日期
  final DateTime? from;

  final SwipableViewController? controller;

  /// 是否可滑动（预留参数，当前未使用）
  final bool? swipable;

  /// 可选日期范围的结束日期
  final DateTime? to;

  /// 当前显示的月份
  final DateTime? current;

  /// 日期是否可用的判断函数
  final DateTimeEnabled? isDateEnabled;

  /// 月份变更回调
  final void Function(DateTime) onChangeMonth;

  final SwipableViewBuilder builder;

  /// 创建可滑动月份视图
  ///
  /// - [from]: 可选日期范围的开始
  /// - [to]: 可选日期范围的结束
  /// - [swipable]: 是否可滑动（预留）
  /// - [isDateEnabled]: 判断日期是否可用
  /// - [onChangeMonth]: 月份变更回调
  /// - [current]: 当前显示的月份
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
  /// 页面控制器，用于管理月份滑动
  late final PageController _controller;

  /// 月份网格数据
  late MonthGridData _grid;

  /// 可选日期范围的开始日期
  late DateTime _from;

  /// 可选日期范围的结束日期
  late DateTime _to;

  /// 滑动范围增量（年数）
  final int _delta = 1;

  /// 当前页面游标
  int _cursor = -1;

  /// 当前选中的日期

  /// 当前显示的月份
  late DateTime _current;

  // get key => null;

  /// 向前追加数据（右滑时）
  ///
  /// 当用户向右滑动到边界时，自动追加更早的月份数据
  _prepend() {
    setState(() {
      _to = _from.copyWith(year: _from.year, month: 12);
      _from = _from.copyWith(year: _from.year - _delta, month: 1);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage(_delta * 12);
    });
  }

  /// 向后追加数据（左滑时）
  ///
  /// 当用户向左滑动到边界时，自动追加更晚的月份数据
  _append() {
    setState(() {
      _from = _to.copyWith(year: _to.year - _delta, month: 1);
      _to = _to.copyWith(year: _to.year + _delta, month: 12);
      _grid = generateCalendar(_from, _to);
      _controller.jumpToPage((_delta + 1) * 12);
    });
  }

  /// 初始化数据
  ///
  /// 根据传入的参数初始化日期范围、当前月份和选中日期
  _generate() {
    DateTime today = getToday();
    _from = widget.from ?? DateTime(today.year - _delta, 1);
    _to = widget.to ?? DateTime(today.year + _delta, 12);
    _grid = generateCalendar(_from, _to);
    _current = widget.current ?? DateTime(today.year, today.month);
  }

  /// 判断两个日期是否相等（仅比较年月）
  bool _internalEqual(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// 查找指定日期在网格中的索引
  int _internalFindIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => _internalEqual(m, date));
  }

  /// 重新生成数据
  ///
  /// 当外部传入的current发生变化时，重新计算日期范围
  _regenerate(DateTime current) {
    _from = current.copyWith(year: current.year - _delta, month: 1);
    _to = current.copyWith(year: current.year + _delta, month: 12);
    _grid = generateCalendar(_from, _to);
    _current = current;
    final slideTo = _internalFindIndex(current);
    if (slideTo != -1) _controller.jumpToPage(slideTo);
    _cursor = -1;
  }

  /// 初始化页面控制器
  _initController() {
    int initialPage = _internalFindIndex(widget.current!);
    // if (initialPage == -1) _internalFindIndex(widget.selected);
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

  /// 触发一次变更回调
  ///
  /// 确保初始显示时触发月份变更回调
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

  /// 页面滑动监听器
  ///
  /// 处理边界滑动时的数据追加逻辑
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

  /// 滑动到下一个月
  next() {
    if (_controller.hasClients) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 滑动到上一个月
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

  /// 月份索引变更处理
  ///
  /// 当页面滑动到新月份时触发回调
  _onIndexChanged(int idx) {
    final m = _monthAt(idx);
    DateTime date = m.copyWith(year: m.year, month: m.month, day: 1);
    _current = m;
    widget.onChangeMonth(date);
  }

  /// 获取指定索引的月份
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
