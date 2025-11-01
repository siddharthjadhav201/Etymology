import 'dart:async';
import 'package:flutter/material.dart';

class TapHandler {
  static const doubleTapDelay = Duration(milliseconds: 250);
  Timer? _tapTimer;
  bool _waitingForSecondTap = false;

  void handleTapDown({
    required TapDownDetails details,
    required VoidCallback onSingleTap,
    required VoidCallback onDoubleTap,
  }) {
    if (_waitingForSecondTap) {
      _tapTimer?.cancel();
      _waitingForSecondTap = false;
      onDoubleTap();
    } else {
      _waitingForSecondTap = true;
      _tapTimer = Timer(doubleTapDelay, () {
        _waitingForSecondTap = false;
        onSingleTap();
      });
    }
  }

  void dispose() {
    _tapTimer?.cancel();
  }
}