import 'package:etymology/highlight_block_formatter.dart';
import 'package:flutter/material.dart';

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

  TextSelection adjustSelection(TextSelection selection,List<HighlightedRange> selectionLocations ){
    var start=selection.start;
    var end=selection.end;
    print("start: $start , end: $end");
   for (var selectionLocation in selectionLocations){
    if(start==selectionLocation.start && end==start+1){
      end+=selectionLocation.length-1;
      print("unhigh= start: $start , end: $end");
      // selectionPositionData.remove(position);
      return TextSelection(baseOffset: start, extentOffset: end ); 
    }
    if (start>selectionLocation.start){
      start+=selectionLocation.length-1;
      end+=selectionLocation.length-1;
    }
   }
   print("start: $start , end: $end");
   return TextSelection(baseOffset: start, extentOffset: end );
  }