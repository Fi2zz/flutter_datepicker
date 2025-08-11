import 'package:flutter/material.dart';

/// Custom title builder type definition
/// 
/// Used to customize the content displayed in the date picker title bar
/// - [context]: Build context
/// - [date]: Currently displayed date
/// - [highlighted]: Whether it's in highlighted state
typedef TitleBuilder = List<Widget> Function(
  BuildContext context,
  DateTime date,
  bool highlighted,
);

/// Date item data class
/// 
/// Contains complete information about a date and its state
class DateItem {
  /// Date
  final DateTime date;

  /// Whether selected
  final bool selected;

  /// Whether enabled
  final bool enabled;

  DateItem({required this.date, required this.selected, required this.enabled});
}

/// Date availability check function type definition
/// 
/// - [DateTime]: Date to check
/// Returns whether the date is available
typedef DateTimeEnabled = bool Function(DateTime);

/// Date item builder type definition
/// 
/// - [context]: Build context
/// - [item]: Object containing date information
typedef DateItemBuilder = Widget Function(BuildContext context, DateItem item);

/// Swipable view builder type definition
/// 
/// - [context]: Build context
/// - [item]: Date item for the view
typedef SwipableViewBuilder = Widget Function(BuildContext context, DateTime item);