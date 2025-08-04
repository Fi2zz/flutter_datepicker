import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';
import 'package:flutter_datepicker/datepicker/datepicker.dart';

// ignore: must_be_immutable
class HeaderView extends StatefulWidget {
  final DateTime current;
  final DateTime? from, to;
  final ValueChanged<DateTime> onMonthChange;
  final ValueChanged<bool> onToggleControl;
  final bool showMonthControl;

  HeaderView({
    super.key,
    DateTime? current,
    required this.showMonthControl, // = true,
    this.from,
    this.to,
    required this.onToggleControl,
    required this.onMonthChange,
  }) : current = current ?? DateTime.now();
  @override
  State<HeaderView> createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> {
  void _prevMonth() {
    final prev = DateTime(widget.current.year, widget.current.month - 1);
    if (widget.from == null ||
        !prev.isBefore(DateTime(widget.from!.year, widget.from!.month))) {
      widget.onMonthChange(prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(widget.current.year, widget.current.month + 1);
    if (widget.to == null ||
        !next.isAfter(DateTime(widget.to!.year, widget.to!.month))) {
      widget.onMonthChange(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> controls = [];
    if (widget.showMonthControl) {
      controls = [
        Padding(
          padding: EdgeInsetsGeometry.only(right: 16),
          child: GestureDetector(
            onTap: _prevMonth,
            child: Icon(CupertinoIcons.chevron_left, size: 20),
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(left: 16),
          child: GestureDetector(
            onTap: _nextMonth,
            child: Icon(CupertinoIcons.chevron_right, size: 20),
          ),
        ),
      ];
    }

    // 顶部标题栏
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => widget.onToggleControl(!widget.showMonthControl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.current.year}年 ${widget.current.month}月',
                style: TextStyle(color: fullBlack, fontWeight: FontWeight.bold),
              ),
              Transform.scale(
                scaleY: 0.5,
                scaleX: 1.0,
                alignment: Alignment.center,
                child: Icon(
                  widget.showMonthControl
                      ? CupertinoIcons.arrowtriangle_down_fill
                      : CupertinoIcons.arrowtriangle_up_fill,
                  size: 16,
                ),
              ),
              // Transform(transform: transform)
            ],
          ),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: controls),
      ],
    );
  }
}
