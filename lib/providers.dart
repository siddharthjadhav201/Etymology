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
  // final List<List<int>> highlightedWordSelectionLocations= [];
  final List<HighlightedRange> highlightedRanges=[];  //for disable editing highlighred words
  final Set<String> _grammaticalWords = {"is", "are", "the", "of", "to", "in", "on", "and","as","a","it","for","like","or","from","with","such","about","often"};
  List highlightedWords=[];
  int prevTextLength=0;
  Set<String> get grammaticalWords => _grammaticalWords;
  Map highlightWordsData={};
  Map activePopUpInfo={};
  TextEditingController? noteController;
  bool isAnnotated = false;

  setAnnotatedStatus(bool value){
    isAnnotated=value;
    notifyListeners();
  }

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
    if ( !highlightedWords.contains(word) && highlightedWords.length < 10) {
      if(highlightedWords.length == 10){
        return false;
      }else{
           highlightedWords.add(word);
      // highlightedWordLocations.add([start,end]);
      highlightedRanges.add(HighlightedRange(start, end ,word.length,start),);
      // highlightedWordSelectionLocations.add([start,word.length]);
      log("$highlightedWords");
      // log("$highlightedWordLocations");
      notifyListeners();
      return true;
      }
    } else {
      print("removing");
         List<int> allStarts = highlightedRanges.map((e) => e.start).toList();
      if(allStarts.contains(start)){
        highlightedRanges.removeAt(highlightedWords.indexOf(word));
      for(var i in highlightedRanges){
        print(i.start);
      }
      highlightedWords.remove(word);
      log("$highlightedWords");
      // log("$highlightedWordLocations");
      notifyListeners();
      return true;
      }else{
        log("show message");
        return true;

      }
     
      
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
    // highlightedWordLocations.clear();
    highlightWordsData.clear();
    highlightedRanges.clear();
    isAnnotated=false;
    notifyListeners();
  }

   void setHighlightWordsData(Map newHighlightWordsData){
    highlightWordsData=newHighlightWordsData;
    notifyListeners();
  }

toggleInfoPopUp(Offset position,String word){
  showPopupAtFixedPosition(homeScreenContext!,position,word);
  // Size screenSize=MediaQuery.of(homeScreenContext!).size;
  // List relativePosition=[position.dx/screenSize.width,position.dy/screenSize.height];
  // if(activePopUpInfo.containsKey(word)){
  //   activePopUpInfo.remove(word);
  //   print(activePopUpInfo);
  //   notifyListeners();
  // }else{
  //   activePopUpInfo.addAll({word:relativePosition});
  //   print(activePopUpInfo);
  //   notifyListeners();
  // }
}
}



