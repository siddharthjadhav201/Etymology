import 'dart:developer';

import 'package:etymology/highlight_block_formatter.dart';
import 'package:flutter/widgets.dart';

bool containsSymbol(String input) {
  final symbolRegex = RegExp(r'[^\w\s]');
  return symbolRegex.hasMatch(input);
}

bool isAlphanumeric(String char) {
  return RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
}

bool isSymbol(String char) {
  return !RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
}

List<List> getFittingText({
  required String text,
  required List<HighlightedRange> highlightedWords,
}) {

  List<HighlightedRange> highlightedRanges=highlightedWords.map((e) => e).toList();
  highlightedRanges.sort((a, b) => a.start.compareTo(b.start));
  int index=0;
  List<List> subParagraph = [];
  double maxWidth = 550;
  double maxHeight = 100;
  TextStyle style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  final TextPainter tp = TextPainter(
    textDirection: TextDirection.ltr,
  );
int globalResult=0;

  while (true) {
    
    List<HighlightedRange> subParagraphHighlightedRanges = [];
    // print(text);
    log("in loop");
    int start = 0;
    int end = text.length;
    int result = 0;

    while (start <= end) {
      int mid = (start + end) ~/ 2;
      tp.text = TextSpan(text: text.substring(0, mid), style: style);
      tp.layout(maxWidth: maxWidth);
      if (tp.height <= maxHeight) {
        result = mid;
        start = mid + 1;
      } else {
        end = mid - 1;
      }
    }
    try{
       int count=0;
       while(index<highlightedRanges.length){
        if(highlightedRanges[index].end>result+globalResult){
          break;
        }
      subParagraphHighlightedRanges.add(highlightedRanges[index]);
      if(count==2){
        result=highlightedRanges[index].end-globalResult;
        log("stopped at : ${highlightedRanges[index].word}");
        index++;
        count++;
        break;
      }
      index++;
      count++;
      
    }
    }catch (e){
      log("error in finding words in subpara");
      log("$e");
    }
   
    globalResult+=result;
    subParagraph.add([text.substring(0, result),subParagraphHighlightedRanges]);
    // print(text.substring(0, result));
    log("substring returned");
    if (text.length == result) {
      break;
    }
    print("${text.length} == $result");
    
    text = text.substring(result);
  }
  return subParagraph;
}
