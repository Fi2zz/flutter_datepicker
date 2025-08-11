import 'package:flutter/widgets.dart';
import '../widgets/common_widgets.dart';

/// 年份选择视图组件
/// 
/// 提供年份网格选择功能，支持垂直滚动和无限加载
class YearsView extends StatefulWidget {
  /// 当前选中的年份
  final int? value;
  
  /// 年份选择回调
  final ValueChanged<int> onSelect;
  
  /// 可选年份范围的开始年份
  final int? from;
  
  /// 可选年份范围的结束年份
  final int? to;

  /// 自定义年份项构建器
  final Widget Function(BuildContext context, int year, bool selected) itemBuilder;

  /// 创建年份选择视图
  /// 
  /// - [value]: 当前选中的年份
  /// - [onSelect]: 年份选择回调
  /// - [from]: 可选年份范围的开始
  /// - [to]: 可选年份范围的结束
  /// - [itemBuilder]: 自定义年份项构建器
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
  /// 网格列数（每行4列）
  static const int _columns = 4;
  
  /// 边缘追加页数
  static const int _preloads = 10;
  
  /// 年份列表
  final List<int> _years = [];
  
  /// 页面控制器
  late PageController _controller;
  
  /// 是否首次布局
  bool _firstLayout = true;
  
  /// 加载锁，防止递归加载
  bool _loading = false;
  
  /// 根据父级约束计算行数
  /// 
  /// - [constraint]: 父级约束
  /// 返回可显示的行数
  int _calcRows(BoxConstraints constraint) {
    final cellWidth = constraint.maxWidth / _columns;
    final cellHeight = cellWidth / 2; // 高 = 宽/2
    return (constraint.maxHeight / cellHeight).floor();
  }

  /// 计算每页的项数
  int _perPage(BoxConstraints c) => _calcRows(c) * _columns;

  /// 初始化年份列表
  /// 
  /// 根据父级约束计算初始年份范围
  void _initYears(BoxConstraints c) {
    final now = DateTime.now().year;
    final perPage = _perPage(c);
    final start = widget.from ?? now - 3 * perPage;
    final end = widget.to ?? now + 3 * perPage;
    _years.addAll(List.generate(end - start + 1, (i) => start + i));
  }

  /// 计算默认滚动到的页码
  /// 
  /// 根据当前选中年份计算初始页码
  int _targetPage(BoxConstraints c) {
    final targetYear = widget.value ?? DateTime.now().year;
    return ((targetYear - _years.first) / _perPage(c)).floor();
  }

  /// 向前/向后追加年份数据
  /// 
  /// 当用户滚动到边界时，自动追加更多年份
  /// - [c]: 父级约束
  /// - [prepend]: true表示向前追加，false表示向后追加
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
  /// 
  /// 当用户滚动到边界时，检查是否需要加载更多年份
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

  /// 根据约束计算页数
  int _itemCountByConstraints(BoxConstraints constraints) {
    return (_years.length / _perPage(constraints)).ceil();
  }

  /// 获取指定页的年份列表
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

  /// 构建单页年份网格
  /// 
  /// - [pageIndex]: 页码
  /// - [constraints]: 父级约束
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
