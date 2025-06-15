import 'dart:developer';

import 'package:flutter/material.dart';

class HighlightProvider with ChangeNotifier {
  final Map _highlightedWords = {};
  Map get highlightedWords => _highlightedWords;

  bool toggleHighlight(String word,int start,int end) {
    if (_highlightedWords.containsKey(word)) {
      _highlightedWords.remove(word);
      log("$_highlightedWords");
      notifyListeners();
      return true;
    } else if (_highlightedWords.length < 10) {
      _highlightedWords.addAll({word:[start,end]});
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool isHighlighted(String word) {
    return _highlightedWords.containsKey(word);
  }

  void clear() {
    _highlightedWords.clear();
    notifyListeners();
  }
}
