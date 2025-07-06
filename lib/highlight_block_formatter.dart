import 'dart:developer';

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
    try{
      for (final range in blockedRanges) {
      if (_hasIntersection(
          range, oldValue.selection, newValue.selection, newValue.text)) {
        // Prevent change
        return oldValue;
      }
    }
    }catch(e){
      log("error in calling _hasIntersection");
    }

//update locations
    try {
      var highlightProvider = context.read<HighlightProvider>();
      List highlightedWordLocations =
          highlightProvider.highlightedWordLocations;
      int diff = newValue.text.length - oldValue.text.length;
      int index = 0;
      log("previous locations: $highlightedWordLocations");
      for (List highlightedWordLocation in highlightedWordLocations) {
        log("update locations $highlightedWordLocation");
        List newHighlightedWordLocation = [];
        if (highlightedWordLocation[0] > oldValue.selection.start - 2) {
          log("in the loop $index");
          newHighlightedWordLocation.add(highlightedWordLocation[0] + diff);
          newHighlightedWordLocation.add(highlightedWordLocation[1] + diff);
          highlightProvider.highlightedRanges[index] = HighlightedRange(
              newHighlightedWordLocation[0], newHighlightedWordLocation[1]);
          highlightProvider.highlightedWordLocations[index] =
              newHighlightedWordLocation;
          log("$index updated locations for highlighted words : ${newHighlightedWordLocation[0]} , ${newHighlightedWordLocation[1]}");
        }
        index++;
      }
      log("highlighted word locations : ${highlightProvider.highlightedWordLocations}");
      log("****returning new value");
      return newValue;
    } catch (e) {
      log("error in updating location");
      return oldValue;
    }
  }

  bool _hasIntersection(
    HighlightedRange range,
    TextSelection oldSelection,
    TextSelection newSelection,
    String newText,
  ) {
    try {
      if (oldSelection.end <= range.start) {
        if (oldSelection.end == range.start) {
          log("checking for front space");
          return newSelection.end==0 ? false : isAlphanumeric(newText[newSelection.end - 1]);
        }
        return false;
      } else if (oldSelection.start >= range.end &&
          newSelection.start >= range.end) {
        if (newSelection.start == range.end ||
            oldSelection.start == range.end) {
          log("checking for last space");
          log("${range.end == newSelection.end}");
          return isAlphanumeric(newText[range.end]);
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
  final int start;
  final int end;
  HighlightedRange(this.start, this.end);
}
