import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import './helpers.dart';
import 'dart:math';

/// 淡入淡出组件
///
/// 根据visible参数控制子组件的显示和隐藏，带有淡入淡出动画效果
class FadeInOut extends StatelessWidget {
  /// 动画持续时间（300毫秒）
  final Duration duration = const Duration(milliseconds: 300);

  /// 子组件
  final Widget child;

  /// 是否可见
  final bool visible;

  /// 创建淡入淡出组件
  ///
  /// - [child]: 子组件
  /// - [visible]: 是否可见
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

/// 可点击组件
///
/// 包装GestureDetector，提供统一的触摸交互控制
/// 当tappable为false时，所有触摸事件将被禁用
class Tappable extends StatelessWidget {
  /// 是否可点击
  final bool tappable;

  /// 点击回调
  final GestureTapCallback? onTap;

  /// 按下回调
  final GestureTapDownCallback? onTapDown;

  /// 抬起回调
  final GestureTapUpCallback? onTapUp;

  /// 取消回调
  final GestureTapCancelCallback? onTapCancel;

  /// 双击回调
  final GestureTapCallback? onDoubleTap;

  /// 长按回调
  final GestureLongPressCallback? onLongPress;

  /// 拖动开始回调
  final GestureDragStartCallback? onPanStart;

  /// 拖动更新回调
  final GestureDragUpdateCallback? onPanUpdate;

  /// 拖动结束回调
  final GestureDragEndCallback? onPanEnd;

  /// 拖动取消回调
  final GestureDragCancelCallback? onPanCancel;

  /// 缩放开始回调
  final GestureScaleStartCallback? onScaleStart;

  /// 缩放更新回调
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// 缩放结束回调
  final GestureScaleEndCallback? onScaleEnd;

  /// 触摸行为
  final HitTestBehavior? behavior;

  /// 是否排除语义
  final bool excludeFromSemantics;

  /// 拖动开始行为
  final DragStartBehavior dragStartBehavior;

  /// 子组件
  final Widget child;

  /// 创建可点击组件
  ///
  /// - [tappable]: 是否可点击，为false时所有触摸事件禁用
  /// - [onTap]: 点击回调
  /// - [onTapDown]: 按下回调
  /// - [onTapUp]: 抬起回调
  /// - [onTapCancel]: 取消回调
  /// - [onDoubleTap]: 双击回调
  /// - [onLongPress]: 长按回调
  /// - [child]: 子组件
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

/// 箭头按钮组件
///
/// 提供左右箭头按钮，支持点击状态反馈（按下透明度变化）
class Chevron extends StatefulWidget {
  /// 点击回调
  final GestureTapCallback? onTap;

  /// 箭头类型，'left'或'right'
  final String type;

  /// 图标大小
  final double size;

  /// 是否可点击
  final bool? touchable;

  /// 创建箭头按钮
  ///
  /// - [type]: 箭头类型，'left'或'right'
  /// - [onTap]: 点击回调
  /// - [size]: 图标大小，默认为24
  /// - [touchable]: 是否可点击
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

/// 箭头按钮状态类
class _ChevronState extends State<Chevron> {
  /// 透明度状态，用于点击反馈
  double _opacity = 1.0;

  /// 获取对应方向的图标
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

/// 可旋转箭头组件
///
/// 提供箭头旋转动画效果，用于展开/收起状态指示
class RotatableCheronRight extends StatefulWidget {
  /// 图标大小
  final double size;

  /// 是否激活（展开状态）
  final bool? active;

  /// 创建可旋转箭头
  ///
  /// - [size]: 图标大小
  /// - [active]: 是否激活，true时箭头旋转90度
  const RotatableCheronRight({super.key, required this.size, this.active});

  @override
  State<StatefulWidget> createState() {
    return _RotatableCheronRightState();
  }
}

/// 可旋转箭头状态类
class _RotatableCheronRightState extends State<RotatableCheronRight>
    with TickerProviderStateMixin {
  /// 动画控制器
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
