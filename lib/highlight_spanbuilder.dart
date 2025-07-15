import 'dart:async';
import 'dart:developer';

// import 'package:flutter/gestures.dart';
import 'package:etymology/description_pop_up.dart';
import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/popUps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'providers.dart';

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;
  final BuildContext context;
  Timer? tapTimer;
  Offset lastTapPosition = Offset.zero;
  final Duration doubleTapDelay = Duration(milliseconds: 350);
  HighlightSpanBuilder(this.highlightProvider, this.context);

  // handleDoubleTap(int start, int end){
  //   log("Double tapped");
  //   highlightProvider.noteController!.selection=TextSelection(baseOffset: start, extentOffset: end);
  // }
  // handleSingleTap(String word){
  //    log("Single Tapped on word: $word");
  //   showPopupAtFixedPosition(context,lastTapPosition,word);
  // }

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    try {
      final List<InlineSpan> children = [];
      // final wordRegEx = RegExp(r'(\s+|\S+)'); // Captures both words and spaces
      // final matches = wordRegEx.allMatches(data);
      List highlightedRangesReference = highlightProvider.highlightedRanges;
      List highlightedRanges=highlightedRangesReference.map((e) => e).toList();
      // List wordLocations=highlightedWords.values.toList();
      highlightedRanges.sort((a, b) => a.start.compareTo(b.start));
      int globalStart = 0;

      for (HighlightedRange highlightedRange in highlightedRanges) {
        final key = GlobalKey();
        children.add(TextSpan(
          text: data.substring(globalStart, highlightedRange.start),
          style: textStyle?.copyWith(
            backgroundColor: null,
          ),
        ));
        children.add(WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: MouseRegion(
                key: key,
                onEnter: (_) {
            final info = highlightProvider.highlightWordsData[data.substring(highlightedRange.start, highlightedRange.end)];
            if (info != null && info.isNotEmpty) {
              OverlayHelper.showTooltip(
                context: context,
                key: key,
                info: info,
              );
            }
          },
          onExit: (_) {
            OverlayHelper.removeTooltip();
          },

                child: Text(
                    data.substring(
                        highlightedRange.start, highlightedRange.end),
                    style: textStyle?.copyWith(
                      backgroundColor: const Color.fromARGB(150, 250, 193, 22),
                    )))));
        globalStart = highlightedRange.end;
      }
      children.add(TextSpan(
        text: data.substring(globalStart),
        style: textStyle?.copyWith(
          backgroundColor: null,
        ),
      ));

      return TextSpan(children: children, style: textStyle);
    } catch (e) {
      log("***error in rendering : $e");
      return TextSpan();
    }
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      required int index}) {
    throw UnimplementedError();
  }
}
