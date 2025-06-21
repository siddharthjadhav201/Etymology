import 'dart:developer';

import 'package:flutter/material.dart';

class HighlightProvider with ChangeNotifier {
  final List highlightedWordLocations= [];
  final Set<String> _grammaticalWords = {"is", "are", "the", "of", "to", "in", "on", "and"};
  // Map get highlightedWords => _highlightedWords;
  List highlightedWords=[];
  int prevTextLength=0;
  Set<String> get grammaticalWords => _grammaticalWords;

  void setPrevTextLength(int newLength){
    prevTextLength=newLength;
    ChangeNotifier();
  }

  void addGrammaticalWord(String word) {
    _grammaticalWords.add(word.trim().toLowerCase());
    notifyListeners();
  }

  void removeGrammaticalWord(String word) {
    _grammaticalWords.remove(word.trim().toLowerCase());
    notifyListeners();
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

  bool isGrammatical(String word) {
    return _grammaticalWords.contains(word.toLowerCase());
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
