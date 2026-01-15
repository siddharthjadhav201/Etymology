

import 'dart:js_util' as js;
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:etymology/highlight_block_formatter.dart';


Future<void> callGeneratePDFWeb({
  required String paragraph,
  required List<List> highlightedWords,
  required List<List> highlightWordsData,
  required List words,
}) async {
  final result = await js.promiseToFuture<List<dynamic>>(
    js.callMethod(
      js.globalThis,
      'genaratePDF',
      [
        paragraph,
        highlightedWords,
        highlightWordsData,
        words,
      ],
    ),
  );

  // final bytes = Uint8List.fromList(result.cast<int>());

  // final blob = html.Blob([bytes], 'application/pdf');
  // final url = html.Url.createObjectUrlFromBlob(blob);

  // html.AnchorElement(href: url)
  //   ..download = 'notes.pdf'
  //   ..click();

  // html.Url.revokeObjectUrl(url);
}

List<List> toJsHighlightedWords(
    List<HighlightedRange> list) {
      List<List> finalList=[];
      for(HighlightedRange e in list){
        List data=[];
        data.add(e.start);
        data.add(e.end);
        data.add(e.word);
        finalList.add(data);
      }
  return finalList;
}


List<List> toJsHighlightedWordsData(
    Map dataMap) {
      List<List> finalList=[];
      for(String key in dataMap.keys){
        List data=[];
        data.add(dataMap[key]["medical_term"]);
        data.add(dataMap[key]["meaning"]);
        finalList.add(data);
      }
  return finalList;
}
  


