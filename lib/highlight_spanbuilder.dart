import 'dart:developer';
import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/tapHandler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'providers.dart';

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;
  final BuildContext context;
  final TextEditingController controller;

  HighlightSpanBuilder(this.highlightProvider,this.context,this.controller);

 @override
TextSpan build(String data, {TextStyle? textStyle, onTap}) {
  try{
      final List<InlineSpan> children = [];
      final TapHandler tapHandler = TapHandler();
  // final wordRegEx = RegExp(r'(\s+|\S+)'); // Captures both words and spaces
  // final matches = wordRegEx.allMatches(data);
  List highlightedRangesReference = highlightProvider.highlightedRanges;
      List highlightedRanges=highlightedRangesReference.map((e) => e).toList();
      // List wordLocations=highlightedWords.values.toList();
      highlightedRanges.sort((a, b) => a.start.compareTo(b.start));
  int globalStart=0;
  for (HighlightedRange highlightedWordsLocation in highlightedRanges) {
    children.add(TextSpan(
      text: data.substring(globalStart,highlightedWordsLocation.start),
      style: textStyle?.copyWith(
        backgroundColor: null,
      ),
    ));
    
    final String word = data.substring(highlightedWordsLocation.start,highlightedWordsLocation.end).toLowerCase();
    final bool isAnnotated = highlightProvider.isAnnotated;
    
    // Only add tap recognizer (which shows hand cursor) if annotation has been done
    if (isAnnotated) {
      children.add(TextSpan(
        recognizer: TapGestureRecognizer()
        ..onTapDown = (details) {
          tapHandler.handleTapDown(
            details: details,
            onSingleTap: () {
              Map<String, dynamic> info = highlightProvider.highlightWordsData[word] ?? {
                "medical_term": word,
                "meaning": "Information currently unavailable"
              };
              print(" Single Tap Detected at ${details.globalPosition}");
              highlightProvider.insertDescriptionPopUp(context,details.globalPosition,info);
            },
            onDoubleTap: () async{
              print(" Double Tap Detected at ${details.globalPosition}");
              await highlightProvider.changeEditorFocusState;
              controller.selection=TextSelection(baseOffset: highlightedWordsLocation.start, extentOffset: highlightedWordsLocation.end);
            },
          );
        },
        text: data.substring(highlightedWordsLocation.start,highlightedWordsLocation.end),
        style: textStyle?.copyWith(
              backgroundColor: Colors.yellow.withAlpha(128),
            ),
      ));
    } else {
      // Before annotation: no tap recognizer, no hand cursor
      children.add(TextSpan(
        text: data.substring(highlightedWordsLocation.start,highlightedWordsLocation.end),
        style: textStyle?.copyWith(
              backgroundColor: Colors.yellow.withAlpha(128),
            ),
      ));
    }
    globalStart=highlightedWordsLocation.end;
  }
  children.add(TextSpan(
      text: data.substring(globalStart),
      style: textStyle?.copyWith(
        backgroundColor: null,
      ),
    ));

  return TextSpan(children: children, style: textStyle);

  }catch(e){
    log("***error in rendering : $e");
    return TextSpan();
  }


  }
  
  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    throw UnimplementedError();
  }

}