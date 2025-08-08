import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import './helpers.dart';
import 'dart:math';

class FadeInOut extends StatelessWidget {
  final Duration duration = const Duration(milliseconds: 300);
  final Widget child;
  final bool visible;
  const FadeInOut({super.key, required this.child, required this.visible});
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0, // 直接受控
      duration: duration,
      curve: Curves.easeInOut,
      child: IgnorePointer(ignoring: visible == false, child: child),
    );
  }
}

class Tappable extends StatelessWidget {
  final bool tappable;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final DragStartBehavior dragStartBehavior;

  final Widget child;

  const Tappable({
    super.key,
    this.tappable = true,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // touchable 为 false 时，全部回调置 null
    return GestureDetector(
      onTap: tappable ? onTap : null,
      onTapDown: tappable ? onTapDown : null,
      onTapUp: tappable ? onTapUp : null,
      onTapCancel: tappable ? onTapCancel : null,
      onDoubleTap: tappable ? onDoubleTap : null,
      onLongPress: tappable ? onLongPress : null,
      onPanStart: tappable ? onPanStart : null,
      onPanUpdate: tappable ? onPanUpdate : null,
      onPanEnd: tappable ? onPanEnd : null,
      onPanCancel: tappable ? onPanCancel : null,
      onScaleStart: tappable ? onScaleStart : null,
      onScaleUpdate: tappable ? onScaleUpdate : null,
      onScaleEnd: tappable ? onScaleEnd : null,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      dragStartBehavior: dragStartBehavior,
      child: child,
    );
  }
}

class Chevron extends StatefulWidget {
  final GestureTapCallback? onTap;
  final String type;
  final double size;
  final bool? touchable;
  const Chevron({
    super.key,

    this.touchable,
    this.onTap,
    required this.type,
    this.size = 24,
  });
  @override
  State<Chevron> createState() => _ChevronState();
}

class _ChevronState extends State<Chevron> {
  double _opacity = 1.0;
  Widget get _icon {
    IconData icon = widget.type == 'left'
        ? CupertinoIcons.chevron_left
        : CupertinoIcons.chevron_right;
    return Icon(icon, size: widget.size, weight: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      tappable: widget.touchable != false,
      onTapDown: (_) => setState(() => _opacity = 0.4), // 按下变透明
      onTapUp: (_) => setState(() => _opacity = 1.0), // 松手恢复
      onTapCancel: () => setState(() => _opacity = 1.0), // 取消恢复
      onTap: widget.onTap,
      child: Opacity(
        opacity: _opacity,
        child: SizedBox(
          height: Helpers.baseNodeHeight,
          width: Helpers.baseNodeHeight,
          child: _icon,
        ),
      ),
    );
  }
}

class RotatableCheronRight extends StatefulWidget {
  final double size;
  final bool? active;
  const RotatableCheronRight({super.key, required this.size, this.active});
  @override
  State<StatefulWidget> createState() {
    return _RotatableCheronRightState();
  }
}

class _RotatableCheronRightState extends State<RotatableCheronRight>
    with TickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this, // 在 State 里
  );
  @override
  void dispose() {
    super.dispose();
    animation.dispose();
  }

  @override
  void didUpdateWidget(covariant RotatableCheronRight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == true) {
      animation.forward();
    } else if (widget.active == false) {
      animation.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Transform.rotate(
          angle: (animation.value * pi / 2),
          alignment: Alignment.center,
          child: Icon(CupertinoIcons.chevron_right, size: widget.size),
        );
      },
    );
  }
}
