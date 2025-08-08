import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/src/widgets.dart';

class YearsView extends StatefulWidget {
  final int? value; // 当前已选年份
  final ValueChanged<int> onSelect; // 选中回调
  final int? from; // 可选开始
  final int? to; // 可选结束

  final Widget Function(BuildContext context, int year, bool selected)
  itemBuilder;

  const YearsView({
    super.key,
    this.value,
    this.from,
    this.to,
    required this.onSelect,
    required this.itemBuilder,
  });
  @override
  State<YearsView> createState() => _YearsViewState();
}

class _YearsViewState extends State<YearsView> {
  // 常量
  static const int _columns = 4; // 每行 4 列
  static const int _preloads = 10; // 边缘追加页数
  // 数据
  final List<int> _years = []; // 年份列表
  late PageController _controller; // PageView 控制器
  bool _firstLayout = true; // 仅首次布局
  bool _loading = false; // 防递归锁
  /// 根据父级约束计算行数
  int _calcRows(BoxConstraints constraint) {
    final cellWidth = constraint.maxWidth / _columns;
    final cellHeight = cellWidth / 2; // 高 = 宽/2
    return (constraint.maxHeight / cellHeight).floor();
  }

  /// 每页 item 数量
  int _perPage(BoxConstraints c) => _calcRows(c) * _columns;

  /// 初始化年份列表
  void _initYears(BoxConstraints c) {
    final now = DateTime.now().year;
    final perPage = _perPage(c);
    final start = widget.from ?? now - 3 * perPage;
    final end = widget.to ?? now + 3 * perPage;
    _years.addAll(List.generate(end - start + 1, (i) => start + i));
  }

  /// 计算默认滚动到的页码
  int _targetPage(BoxConstraints c) {
    final targetYear = widget.value ?? DateTime.now().year;
    return ((targetYear - _years.first) / _perPage(c)).floor();
  }

  /// 向前/向后追加数据
  void _append(BoxConstraints c, {bool prepend = false}) {
    if (_loading) return;
    _loading = true;
    final perPage = _perPage(c);
    setState(() {
      if (prepend) {
        final newStart = _years.first - perPage * _preloads;
        _years.insertAll(
          0,
          List.generate(perPage * _preloads, (i) => newStart + i),
        );
        // 保持页码相对位置
        _controller.jumpToPage(_controller.page!.round() + _preloads);
      } else {
        final newEnd = _years.last + perPage * _preloads;
        _years.addAll(
          List.generate(
            perPage * _preloads,
            (i) => newEnd - perPage * _preloads + 1 + i,
          ),
        );
      }
    });
    // 解锁
    WidgetsBinding.instance.addPostFrameCallback((_) => _loading = false);
  }

  /// 滚动结束检查是否需要追加
  void _handleScrollEnd(BoxConstraints c) {
    if (_loading) return;
    final page = _controller.page!.round();
    final totalPages = (_years.length / _perPage(c)).ceil();
    if (page < _preloads) {
      _append(c, prepend: true);
    } else if (page >= totalPages - _preloads) {
      _append(c, prepend: false);
    }
  }

  int _itemCountByConstraints(BoxConstraints constraints) {
    return (_years.length / _perPage(constraints)).ceil();
  }

  List<int> _yearsCountByConstraint(BoxConstraints constraints, int pageIndex) {
    final start = pageIndex * _perPage(constraints);
    final end = (start + _perPage(constraints)).clamp(0, _years.length);
    return _years.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 获取父级约束
    return LayoutBuilder(
      builder: (context, constraints) {
        // 仅在第一次布局时初始化
        if (_firstLayout) {
          _initYears(constraints);
          _controller = PageController(initialPage: _targetPage(constraints));
          _firstLayout = false;
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _handleScrollEnd(constraints);
            }
            return false;
          },
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            pageSnapping: false, // 关闭回弹/吸附
            physics: const ClampingScrollPhysics(), // 禁用 iOS 回弹
            itemCount: _itemCountByConstraints(constraints),
            itemBuilder: (_, pageIndex) =>
                _buildPage(context, pageIndex, constraints),
          ),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    int pageIndex,
    BoxConstraints constraints,
  ) {
    final pageYears = _yearsCountByConstraint(constraints, pageIndex);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        childAspectRatio: 2,
      ),
      itemCount: pageYears.length,
      itemBuilder: (_, index) {
        final year = pageYears[index];
        final isSelected = year == widget.value;
        return Tappable(
          onTap: () => widget.onSelect(year),
          child: widget.itemBuilder(context, year, isSelected),
        );
      },
    );
  }
}
