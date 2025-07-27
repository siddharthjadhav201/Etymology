import 'package:flutter/material.dart';
import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/popUps.dart';
import 'dart:developer';


class HighlightProvider with ChangeNotifier {
   BuildContext? homeScreenContext;
   final List<HighlightedRange> highlightedRanges=[];  
  final Set<String> _grammaticalWords = {"is", "are", "the", "of", "to", "in", "on", "and"};
  List<String> highlightedWords = [];
  int prevTextLength = 0;
  Set<String> get grammaticalWords => _grammaticalWords;
  List<Map<String, dynamic>> highlightWordsData = [];
  String? selectedWord;
   Map activePopUpInfo={};
   TextEditingController? noteController;
   bool isAnnotated = false;
  Map<String, dynamic>? selectedInfo;
  final Map<String, GlobalKey> _keys = {};

  setAnnotatedStatus(bool value){
    isAnnotated=value;
    notifyListeners();
  }

  void setPrevTextLength(int newLength) {
    prevTextLength = newLength;
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

  // bool toggleHighlight(String word, int start, int end) {
  //   if (highlightedWords.contains(word)) {
  //     highlightedWordLocations.removeAt(highlightedWords.indexOf(word));
  //     highlightedWords.remove(word);
  //     _keys.remove(word);
  //     notifyListeners();
  //     return true;
  //   } else if (highlightedWords.length < 10) {
  //     highlightedWords.add(word);
  //     highlightedWordLocations.add([start, end]);
  //     _keys[word] = GlobalKey();
  //     notifyListeners();
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

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
    //highlightedWordLocations.clear();
    highlightedRanges.clear();
    highlightWordsData.clear();
    isAnnotated=false;
    notifyListeners();
  }

  void setHighlightWordsData(List<Map<String, dynamic>> newHighlightWordsData) {
    highlightWordsData = newHighlightWordsData;
    notifyListeners();
  }

  GlobalKey getKeyFor(String word) {
  
  if (!_keys.containsKey(word)) {
    _keys[word] = GlobalKey();
  }
  return _keys[word]!;
}

 Map<String, dynamic>? getInfoForWord(String word) {
  final result = highlightWordsData.firstWhere(
    (item) => item['Medical_Term'] == word,
    orElse: () => <String, dynamic>{}, // ✅ return empty map if not found
  );
  
  return Map<String, dynamic>.from(result); // ✅ ensures correct type
}
  void setSelectedWord(String word, Map<String, dynamic> info) {
   selectedWord = word;
   selectedInfo = info;
  notifyListeners();
}
}