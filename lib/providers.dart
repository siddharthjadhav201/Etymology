import 'dart:developer';

import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/popUps.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier{
  String username="sanket855";
  void setUsername(String newUsername){
    username=newUsername;
    notifyListeners();
  }
}

class HighlightProvider with ChangeNotifier {
  BuildContext? homeScreenContext;
  final List<List> highlightedWordLocations= [];
  final List<HighlightedRange> highlightedRanges=[];  //for disable editing highlighred words
  final Set<String> _grammaticalWords = {"is", "are", "the", "of", "to", "in", "on", "and","as","a","it","for","like","or","from","with","such","about","often"};
  // Map get highlightedWords => _highlightedWords;
  List highlightedWords=[];
  int prevTextLength=0;
  Set<String> get grammaticalWords => _grammaticalWords;
  Map highlightWordsData={};
  Map activePopUpInfo={};

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
      highlightedRanges.removeAt(highlightedWords.indexOf(word));
      highlightedWords.remove(word);
      log("$highlightedWords");
      log("$highlightedWordLocations");
      notifyListeners();
      return true;
    } else if (highlightedWords.length < 10) {
      highlightedWords.add(word);
      highlightedWordLocations.add([start,end]);
      highlightedRanges.add(HighlightedRange(start, end),);
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
    highlightWordsData.clear();
    highlightedRanges.clear();
    notifyListeners();
  }

   void setHighlightWordsData(Map newHighlightWordsData){
    highlightWordsData=newHighlightWordsData;
    notifyListeners();
  }

// toggleInfoPopUp(Offset position,String word){
//   showPopupAtFixedPosition(homeScreenContext!,position,word);
//   // Size screenSize=MediaQuery.of(homeScreenContext!).size;
//   // List relativePosition=[position.dx/screenSize.width,position.dy/screenSize.height];
//   // if(activePopUpInfo.containsKey(word)){
//   //   activePopUpInfo.remove(word);
//   //   print(activePopUpInfo);
//   //   notifyListeners();
//   // }else{
//   //   activePopUpInfo.addAll({word:relativePosition});
//   //   print(activePopUpInfo);
//   //   notifyListeners();
//   // }
// }
}



