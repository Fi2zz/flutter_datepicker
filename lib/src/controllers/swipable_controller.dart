import 'package:flutter/material.dart';

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
  void detach() {
    _state = null;
  }
}