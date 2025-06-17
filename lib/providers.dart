import 'dart:developer';

import 'package:flutter/material.dart';

class HighlightProvider with ChangeNotifier {
  final List highlightedWordLocations= [];
  // Map get highlightedWords => _highlightedWords;
  List highlightedWords=[];
  int prevTextLength=0;

  void setPrevTextLength(int newLength){
    prevTextLength=newLength;
    ChangeNotifier();
  }

  bool toggleHighlight(String word,int start,int end) {
    if (highlightedWords.contains(word)) {
      highlightedWordLocations.removeAt(highlightedWords.indexOf(word));
      highlightedWords.remove(word);
      log("$highlightedWords");
      log("$highlightedWordLocations");
      notifyListeners();
      return true;
    } else if (highlightedWords.length < 10) {
      highlightedWords.add(word);
      highlightedWordLocations.add([start,end]);
      log("$highlightedWords");
      log("$highlightedWordLocations");
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool isHighlighted(String word) {
    return highlightedWords.contains(word);
  }

  void clear() {
    highlightedWords.clear();
    highlightedWordLocations.clear();
    notifyListeners();
  }
}
