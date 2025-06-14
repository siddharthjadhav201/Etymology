import 'package:flutter/material.dart';

class HighlightProvider with ChangeNotifier {
  final List<String> _highlightedWords = [];

  List<String> get highlightedWords => _highlightedWords;

  bool toggleHighlight(String word) {
    if (_highlightedWords.contains(word)) {
      _highlightedWords.remove(word);
      notifyListeners();
      return true;
    } else if (_highlightedWords.length < 10) {
      _highlightedWords.add(word);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool isHighlighted(String word) {
    return _highlightedWords.contains(word);
  }

  void clear() {
    _highlightedWords.clear();
    notifyListeners();
  }
}
