import 'dart:developer';

import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/popUps.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier{
  String username="sanket855";
  bool loginLoader=false;
  void setUsername(String newUsername){
    username=newUsername;
    notifyListeners();
  }
  void setLoginLoader(bool value){
    loginLoader=value;
    notifyListeners();
  }
}

class HighlightProvider with ChangeNotifier {
  OverlayState? overlay;
  BuildContext? homeScreenContext;
  // final List<List<int>> highlightedWordSelectionLocations= [];
  final List<HighlightedRange> highlightedRanges=[];  //for disable editing highlighred words
  final Set<String> _grammaticalWords = {"is", "are", "the", "of", "to", "in", "on", "and","as","a","it","for","like","or","from","with","such","about","often"};
  List<String> highlightedWords=[];
  int prevTextLength=0;
  Set<String> get grammaticalWords => _grammaticalWords;
  Map highlightWordsData={};
  TextEditingController? noteController;
  bool isAnnotated = false;
  Widget? descriptionPopUp;
  bool editorFocusState=true;


  changeEditorFocusState(){
    editorFocusState=true;
    notifyListeners();
  }
removeDescriptionPopUp(){
  descriptionPopUp=null;
  notifyListeners();
}  
  insertDescriptionPopUp(BuildContext context,Offset position,Map info){
    descriptionPopUp=Container(
      margin: EdgeInsets.only(left: position.dx,top: position.dy),
          width: 145,
          height: 170,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black)],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (Medical_Term)
                Row(
                  children: [
                    // Image.asset("assets/medical_term_sign.png",
                    // width: 18,
                    // height: 18,),
                    Expanded(
                      child: Text(
                        info['medical_term'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
          
                // Description (Term_Des)
                Text(
                  info['meaning'].substring(0,110)+'...' ?? '',
                  style: TextStyle(fontSize: 10),
                ),
          
                const Divider(height: 20, thickness: 1),
          
                // Origin
                if (info['origin'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "Origin : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['origin']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
          
                // Prefix
                if (info['prefix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "Prefix : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['prefix']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
          
                if (info['suffix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "Suffix : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['suffix']),
                      ],
                    ),
                  ),
              ],
            ),
        );
        notifyListeners();
  }

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
  
  int toggleHighlight(String word,int start,int end) {
    if ( !highlightedWords.contains(word)) {
      if(highlightedWords.length == 10){
        return 1;
      }else{
           highlightedWords.add(word);
      // highlightedWordLocations.add([start,end]);
      highlightedRanges.add(HighlightedRange(start, end ,word.length,start,word),);
      // highlightedWordSelectionLocations.add([start,word.length]);
      log("$highlightedWords");
      // log("$highlightedWordLocations");
      notifyListeners();
      return 0;
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
      return 0;
      }else{
        return 2;
      }
     
      
    }
  }

  int addHighlight(String word, int start, int end) {
    if (highlightedWords.contains(word)) {
      List<int> allStarts = highlightedRanges.map((e) => e.start).toList();
      if (allStarts.contains(start)) {
        return 2; // Already highlighted at this position
      } else {
        return 2; // Word is highlighted but at different position
      }
    }
    
    if (highlightedWords.length == 10) {
      return 1; // Limit reached
    }
    
    highlightedWords.add(word);
    highlightedRanges.add(HighlightedRange(start, end, word.length, start, word));
    log("$highlightedWords");
    notifyListeners();
    return 0; // Success
  }

  int removeHighlight(String word, int start, int end) {
    if (!highlightedWords.contains(word)) {
      return 2; // Word is not highlighted
    }
    
    List<int> allStarts = highlightedRanges.map((e) => e.start).toList();
    if (allStarts.contains(start)) {
      int index = highlightedWords.indexOf(word);
      highlightedRanges.removeAt(index);
      highlightedWords.remove(word);
      log("$highlightedWords");
      notifyListeners();
      return 0; // Success
    } else {
      return 2; // Word is highlighted but at different position
    }
  }

  bool isGrammatical(String word) {
    // Check if entire word is grammatical
    if (_grammaticalWords.contains(word.toLowerCase())) {
      return true;
    }
    // For multi-word selections, check if any individual word is grammatical
    final words = word.trim().split(RegExp(r'\s+'));
    for (String w in words) {
      if (_grammaticalWords.contains(w.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  bool isHighlighted(String word) {
    return highlightedWords.contains(word);
  }

  void clear() {
    descriptionPopUp=null;
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



