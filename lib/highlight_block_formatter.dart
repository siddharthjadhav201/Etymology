import 'dart:developer';

import 'package:etymology/providers.dart';
import 'package:etymology/string_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:etymology/string_functions.dart';


class HighlightBlockFormatter extends TextInputFormatter {
  final List<HighlightedRange> blockedRanges;
  final BuildContext context;
  HighlightBlockFormatter(this.blockedRanges, this.context);
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
     
    log("####");
    log("${oldValue.selection.start},${oldValue.selection.end}");
    log("${newValue.selection.start},${newValue.selection.end}");
    var highlightProvider = context.read<HighlightProvider>();

    TextSelection adjustedOldSelection = adjustSelection(oldValue.selection, highlightProvider.highlightedRanges);
    TextSelection adjustedNewSelection = adjustSelection(newValue.selection, highlightProvider.highlightedRanges);
     int diff = newValue.text.length - oldValue.text.length;
    try{
      for (final range in blockedRanges) {
      if (_hasIntersection(
          range, adjustedOldSelection, adjustedNewSelection, newValue.text ,diff)) {
        // Prevent change
        return oldValue;
      }
    }
    }catch(e){
      log("error in calling _hasIntersection");
    }

//update locations
    try {
    final TextEditingValue adjustedNewValue;
    String editedText="";
     int oldSelectionLength=oldValue.selection.end-oldValue.selection.start;
     log("oldSelectionLength:$oldSelectionLength");
    //  int newSelectionLength=newValue.selection.end-newValue.selection.start;
     if(diff<0&&oldSelectionLength==0){
      log("=>${oldValue.selection.start+1}");
      log("${oldValue.selection.start }  ${oldValue.selection.start+(oldSelectionLength==0?1:oldSelectionLength)+diff}");
      editedText = oldValue.text.substring(oldValue.selection.start,oldValue.selection.start+(oldSelectionLength==0?1:oldSelectionLength)+diff);
       adjustedNewValue= TextEditingValue(text: oldValue.text.substring(0,adjustedOldSelection.start-1)+oldValue.text.substring(adjustedOldSelection.start),
                              selection: TextSelection.collapsed(offset: newValue.selection.start)
      );                                
     }else{
      log("here");
      editedText = newValue.text.substring(oldValue.selection.start,oldValue.selection.start+oldSelectionLength+diff);
      log("end here");
       adjustedNewValue =TextEditingValue(text: oldValue.text.substring(0,adjustedOldSelection.start)+editedText+oldValue.text.substring(adjustedOldSelection.end),
                              selection: TextSelection.collapsed(offset: newValue.selection.start)
      );                 
      
     }


      int index = 0;
      var highlightedRanges=highlightProvider.highlightedRanges;
      for (int i=0;i<highlightedRanges.length;i++) {
        log("in the loop $index");
        if (highlightedRanges[index].start > adjustedOldSelection.start - 2) {
          highlightedRanges[index].start+=diff; 
          highlightedRanges[index].end+=diff; 
        }
        index++;
      }
      // log("new word locations : ${highlightProvider.highlightedWordLocations}");
      log("****returning new value");
      return adjustedNewValue;
      // return newValue;
    } catch (e) {
      log("error in updating location $e");
      return oldValue;
    }
  }

  bool _hasIntersection(
    HighlightedRange range,
    TextSelection oldSelection,
    TextSelection newSelection,
    String newText,
    int diff,
  ) {
    try {
      if (oldSelection.end <= range.start) {
        if (oldSelection.end == range.start ) {
          log("checking for front space");
          log("${newSelection.end>range.start+diff}");
          log(newText[newSelection.end - 1]);
          return newSelection.end==0 ? false : newSelection.end > range.start+diff ? true : isAlphanumeric(newText[newSelection.end-1]);
        }
        return false;
      } else if (oldSelection.start >= range.end &&
          newSelection.start >= range.end) {
        if (newSelection.start == range.end ||
            oldSelection.start == range.end) {
          log("checking for last space");
          log("${range.end == newSelection.end}");
          log(newText[range.end]);
          return isAlphanumeric(newText[range.end+1]);
        }
        return false;
      } else {
        log("highlighted part is selected");
        return true;
      }
    } catch (e) {
      log("error in blocking highlighted words");
      return true;
    }
  }

  // {
  //   final editingRange = TextRange(start: oldSelection.start, end: newSelection.end);
  //   return !(editingRange.end <= range.start || editingRange.start >= range.end);
  // }

    


}

class HighlightedRange {
   int start;
   int end;
   int length;
   int selectIndex;
  HighlightedRange(this.start, this.end ,this.length,this.selectIndex);
}



 