import 'dart:developer';

import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/string_functions.dart';
import 'package:flutter/material.dart';

List<List> getFittingText1(
    {required String text,
    required List<HighlightedRange> highlightedWords,
    required double width}) {
  List<HighlightedRange> highlightedRanges =
      highlightedWords.map((e) => e).toList();
  highlightedRanges.sort((a, b) => a.start.compareTo(b.start));

  List<List> subParagraph = [];
  int globalResult = 0;
  int wordIndex = 0;
  int pageCount = 0;
  while (true) {
    Map? dataForSinglePage = getDataForSinglePage(
        wordIndex, highlightedRanges, text, globalResult, width);
    if (dataForSinglePage != null) {
      print("data received from getDataForSinglePage : ****");
      print("${dataForSinglePage["text"]},${dataForSinglePage["height"]}");
      for (HighlightedRange highlightedRange
          in dataForSinglePage["highlightedWords"]) {
        print(highlightedRange.word);
      }
      print("wordIndex : ${dataForSinglePage["wordIndex"]}");
      print("globalResult : ${dataForSinglePage["globalResult"]}");

      wordIndex = dataForSinglePage["wordIndex"];

      subParagraph.add([
        dataForSinglePage["text"],
        dataForSinglePage["highlightedWords"],
        dataForSinglePage["height"],
        globalResult
      ]);
      globalResult = dataForSinglePage["globalResult"];
    } else {
      break;
    }

    if (globalResult >= text.length || pageCount > 10) {
      break;
    }
    pageCount++;
    print("pageCount : $pageCount");
  }

  return subParagraph;
}

int getCharSizeForContainer(double height, String text, double maxWidth) {
  final TextPainter tp = TextPainter(
    textDirection: TextDirection.ltr,
  );
  try {
    final TextStyle style = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal, // equivalent to pw.FontWeight.normal
  wordSpacing: 1.5,
  height: 1.55,
  fontFamily: "NotoSans" // approximated line spacing to line height ratio // required if used outside Material widgets
);
    int start = 0;
    int end = text.length;
    int currentResult = 0;
    while (start <= end) {
      int mid = (start + end) ~/ 2;
      tp.text = TextSpan(text: text.substring(0, mid), style: style);
      tp.layout(maxWidth: maxWidth);
      if (tp.height <= height) {
        currentResult = mid;
        start = mid + 1;
      } else {
        end = mid - 1;
      }
    }
    return currentResult;
  } catch (e) {
    log("error in : getCharSizeForContainer");
  }
  return 0;
}

Map? getDataForSinglePage(
    int wordIndex,
    List<HighlightedRange> highlightedRanges,
    String text,
    int globalResult,
    double width) {
  print("data gave for getDataForSinglePage : ****");
  print("wordIndex : $wordIndex");
  print("globalResult : $globalResult");

  List availableHeight = [
    343,
    422,
    504,
    584,
    663,
    775
  ]; //[103, 230, 360, 488, 615, 775];
  List availableWord = [5, 4, 3, 2, 1, 0];
  int index = 0;
  try {
    // int result=0;
    while (true) {
      log("index : $index");
      int currentResult = getCharSizeForContainer(
          availableHeight[index], text.substring(globalResult), width);
      int count = 0;
      //  availableWord[index];//7,8
      List<HighlightedRange> highlightedWordsInPara = [];
      while (wordIndex + count < highlightedRanges.length) {
        if (currentResult + globalResult <
            highlightedRanges[wordIndex + count].end) {
          break;
        }

        if (count == availableWord[index]) {
          //GlobalResult
          log("return 1");
          log("$currentResult");
          return {
            "wordIndex": wordIndex + count,
            "text": text.substring(globalResult,
                highlightedRanges[wordIndex + count].start - 1),
            "highlightedWords": highlightedWordsInPara,
            "height": availableHeight[index],
            "globalResult":
                highlightedRanges[wordIndex + count].start - 1
          };
          // break;
        }
        highlightedWordsInPara.add(highlightedRanges[wordIndex + count]);
        count++;
        log("count : $count");
      }

      if (count < availableWord[index]) {
        log("count : $count");
        index++;
      } else {
        int nearestSpace = currentResult + globalResult;
        log(text[nearestSpace - 1]);
        if (nearestSpace < text.length) {
          while (isAlphanumeric(text[nearestSpace - 1])) {
            log(text[nearestSpace - 1]);
            nearestSpace--;
            log("backword for space");
          }
          log(text[nearestSpace - 1]);
        }

        log("return 2");
        // result= currentResult;
        log("$currentResult");
        return {
          "wordIndex": wordIndex + count,
          "text": text.substring(globalResult, nearestSpace),
          "highlightedWords": highlightedWordsInPara,
          "height": availableHeight[index],
          "globalResult": nearestSpace
        };
      }
    }
  } catch (e) {
    log("error in : getDataForSinglePage");
    log("$e");
  }
  return null;
}
