import 'dart:developer';
import 'package:etymology/popUps.dart';
import 'package:etymology/providers.dart';
import 'package:etymology/string_functions.dart';
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
    log("####");
    log("${oldValue.selection.start},${oldValue.selection.end}");
    log("${newValue.selection.start},${newValue.selection.end}");
    var highlightProvider = context.read<HighlightProvider>();
    List<HighlightedRange> highlightedRanges =
        highlightProvider.highlightedRanges;
    int diff = newValue.text.length - oldValue.text.length;
    
    try {
      for (final range in blockedRanges) {
        if (_hasIntersection(range, oldValue.selection, newValue.selection,
            newValue.text, diff)) {
          // Prevent change
           showCenterPopup(context,"highlighted can't be edited! first unhighlight then try to edit");
          return oldValue;
        }
      }
    } catch (e) {
      log("error in calling _hasIntersection");
    }

//update locations
    try {
      int index = 0;
      for (int i = 0; i < highlightedRanges.length; i++) {
        log("in the loop $index");
        log("${highlightedRanges[index].start}");
        log("${highlightedRanges[index].end}");
        log("${oldValue.selection.start}");
        if (highlightedRanges[index].start >= oldValue.selection.start) {
          highlightedRanges[index].start += diff;
          highlightedRanges[index].end += diff;
        }
        index++;
      }
      // log("new word locations : ${highlightProvider.highlightedWordLocations}");
      log("****returning new value");
      return newValue;
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
        if (oldSelection.end == range.start) {
          log("checking for front space");
          return range.start+diff == 0
              ? false
                  : isAlphanumeric(newText[range.start-1+diff]);
        }
        return false;
      } else if (oldSelection.start >= range.end &&
          newSelection.start >= range.end) {
        if (newSelection.start == range.end ||
            oldSelection.start == range.end) {
          log("checking for last space");
          log("${newText.length==range.end}");
          return newText.length==range.end ? false: isAlphanumeric(newText[range.end]);
        }
        return false;
      } else {
        log("highlighted part is selected");
       
        return true;
      }
    } catch (e) {
      log("error in blocking highlighted words $e");
      return true;
    }
  }
}

// TextEditingValue assignNewValue(
//   oldValue, newValue, adjustedOldSelection, highlightedRanges, diff) {
//   final TextEditingValue adjustedNewValue;
//   String editedText = "";
//   int oldSelectionLength = oldValue.selection.end - oldValue.selection.start;
//   //  log("oldSelectionLength:$oldSelectionLength");
//   //  int newSelectionLength=newValue.selection.end-newValue.selection.start;
//   if (diff < 0 && oldSelectionLength == 0) {
//     // log("=>${oldValue.selection.start+1}");
//     // log("${oldValue.selection.start }  ${oldValue.selection.start+(oldSelectionLength==0?1:oldSelectionLength)+diff}");
//     editedText = oldValue.text.substring(
//         oldValue.selection.start,
//         oldValue.selection.start +
//             (oldSelectionLength == 0 ? 1 : oldSelectionLength) +
//             diff);
//     adjustedNewValue = TextEditingValue(
//         text: oldValue.text.substring(0, adjustedOldSelection.start - 1) +
//             oldValue.text.substring(adjustedOldSelection.start),
//         selection: TextSelection.collapsed(offset: newValue.selection.start));
//   } else {
//     // log("here");
//     editedText = newValue.text.substring(oldValue.selection.start,
//         oldValue.selection.start + oldSelectionLength + diff);
//     // log("end here");
//     adjustedNewValue = TextEditingValue(
//         text: oldValue.text.substring(0, adjustedOldSelection.start) +
//             editedText +
//             oldValue.text.substring(adjustedOldSelection.end),
//         selection: TextSelection.collapsed(offset: newValue.selection.start));
//   }
//   return adjustedNewValue;
// }



 class HighlightedRange {
  int start;
  int end;
  int length;
  int selectIndex;
  String word;
  HighlightedRange(this.start, this.end, this.length, this.selectIndex,this.word);
 
}
