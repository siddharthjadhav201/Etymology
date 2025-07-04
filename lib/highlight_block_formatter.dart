import 'dart:developer';

import 'package:etymology/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HighlightBlockFormatter extends TextInputFormatter {
  final List<HighlightedRange> blockedRanges;
  final BuildContext context;
  HighlightBlockFormatter(this.blockedRanges, this.context);
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    for (final range in blockedRanges) {
      
      if (_hasIntersection(range, oldValue.selection, newValue.selection ,newValue.text)) {
        // Prevent change
        return oldValue;
      }
    }

//update locations
    var highlightProvider=context.read<HighlightProvider>();
    List highlightedWordLocations = highlightProvider.highlightedWordLocations;
    int diff = newValue.text.length - oldValue.text.length;
      int index=0;
      log("previous locations: $highlightedWordLocations");
      for (List highlightedWordLocation in highlightedWordLocations){
        log("update locations $highlightedWordLocation");
        List newHighlightedWordLocation=[];
       if( highlightedWordLocation[0] > oldValue.selection.start-2){
        log("in the loop $index");
        newHighlightedWordLocation.add(highlightedWordLocation[0]+diff);
        newHighlightedWordLocation.add(highlightedWordLocation[1]+diff);
        highlightProvider.highlightedRanges[index]=HighlightedRange(newHighlightedWordLocation[0],newHighlightedWordLocation[1]);
        highlightProvider.highlightedWordLocations[index]=newHighlightedWordLocation;
        log("$index updated locations for highlighted words : ${newHighlightedWordLocation[0]} , ${newHighlightedWordLocation[1]}");
       }
       index++;
      }
      log("highlighted word locations : ${highlightProvider.highlightedWordLocations}");
    return newValue;
  } 

  bool _hasIntersection(
    HighlightedRange range,
    TextSelection oldSelection,
    TextSelection newSelection,
    String newText,
  ) 
  {
    if(oldSelection.end<=range.start){
       if(oldSelection.end==range.start){
        log("checking for front space");
        return ![" ","\n","\t"].contains(newText[newSelection.end-1]);
      }
      return false;
    }else if(oldSelection.start>=range.end && newSelection.start>=range.end){
      if(newSelection.start==range.end || oldSelection.start==range.end){
        log("checking for last space");
        
            return ![" ","\n","\t"].contains(newText[range.end]);
      }
      return false;
    }else{
      log("highlighted part is selected");
      return true;
    }
  }
  
  // {
  //   final editingRange = TextRange(start: oldSelection.start, end: newSelection.end);
  //   return !(editingRange.end <= range.start || editingRange.start >= range.end);
  // }
}

class HighlightedRange {
  final int start;
  final int end;
  HighlightedRange(this.start, this.end);
}

