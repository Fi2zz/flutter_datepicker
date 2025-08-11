import 'package:flutter/widgets.dart';
import './helpers.dart';

/// 星期视图组件
/// 
/// 显示星期几的标题栏，通常位于日历顶部
class WeekView extends StatelessWidget {
  /// 星期几的文本列表
  /// 
  /// 通常包含7个元素，如['日', '一', '二', '三', '四', '五', '六']
  final List<String> data;
  
  /// 创建星期视图
  /// 
  /// - [data]: 星期几的文本列表，长度必须为7
  const WeekView({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: [
        for (final date in data)
          Center(
            child: Text(
              date,
              style: TextStyle(color: Helpers.getWeekDayTextColor()),
            ),
          ),
      ],
    );
  }
}
