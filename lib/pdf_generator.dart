import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pd;
import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> generatePdf(
    String fullText, List<HighlightedRange> highlights) async {
  final pdf = pd.Document();
  final fontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
  final ttf = pd.Font.ttf(fontData);

  List<List> subParagraphs =
      getFittingText(text: fullText, highlightedWords: highlights);

  pdf.addPage(
    pd.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pd.EdgeInsets.all(20),
      build: (context) {
        List<pd.Widget> widgets = [];

        for (List part in subParagraphs) {
          final String text = part[0];
          final List<HighlightedRange> subHighlights =
              part[1] as List<HighlightedRange>;

          widgets.add(pd.Container(
            height: 500,
            width: 550,
            child: buildHighlightedText(text, subHighlights, ttf),
          ));

          widgets.add(pd.Container(
            height: 200,
            width: 550,
            child: pd.Column(
              crossAxisAlignment: pd.CrossAxisAlignment.start,
              children: subHighlights.map((h) {
                final f = h.footnoteData;
                return pd.Column(
                  crossAxisAlignment: pd.CrossAxisAlignment.start,
                  children: [
                    pd.Text('Medical Term : ${f['term'] ?? ''}',
                        style: pd.TextStyle(font: ttf, fontSize: 8)),
                    pd.Text('Description : ${f['description'] ?? ''}',
                        style: pd.TextStyle(font: ttf, fontSize: 8)),
                    pd.Text(
                        'Origin : ${f['origin'] ?? ''} prefix : ${f['prefix'] ?? ''} suffix : ${f['suffix'] ?? ''}',
                        style: pd.TextStyle(font: ttf, fontSize: 8)),
                    pd.Text('Definition : ${f['definition'] ?? ''}',
                        style: pd.TextStyle(font: ttf, fontSize: 8)),
                    pd.SizedBox(height: 2),
                  ],
                );
              }).toList(),
            ),
          ));

          widgets.add(pd.SizedBox(height: 20));
        }

        return widgets;
      },
    ),
  );

  final bytes = await pdf.save();
  downloadPDF(bytes);
}

pd.RichText buildHighlightedText(
    String text, List<HighlightedRange> highlights, pd.Font font) {
  final spans = <pd.InlineSpan>[];
  int pointer = 0;
  highlights.sort((a, b) => a.start.compareTo(b.start));

  for (final h in highlights) {
    if (pointer < h.start) {
      spans.add(pd.TextSpan(
        text: text.substring(pointer, h.start),
        style: pd.TextStyle(font: font, fontSize: 11),
      ));
    }

    spans.add(pd.TextSpan(
      text: text.substring(h.start, h.end),
      style: pd.TextStyle(
        font: font,
        fontSize: 11,
        background: pd.BoxDecoration(color: PdfColors.yellow,)
      ),
    ));

    pointer = h.end;
  }

  if (pointer < text.length) {
    spans.add(pd.TextSpan(
      text: text.substring(pointer),
      style: pd.TextStyle(font: font, fontSize: 11),
    ));
  }

  return pd.RichText(text: pd.TextSpan(children: spans));
}

List<List> getFittingText({
  required String text,
  required List<HighlightedRange> highlightedWords,
}) {
  List<HighlightedRange> sortedHighlights = [...highlightedWords];
  sortedHighlights.sort((a, b) => a.start.compareTo(b.start));

  List<List> subParagraphs = [];
  int globalStart = 0;
  int index = 0;

  while (globalStart < text.length) {
    int result = 0;
    int start = 0;
    int end = text.length - globalStart;
    int highlightCount = 0;
    List<HighlightedRange> currentHighlights = [];

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    const style = TextStyle(fontSize: 11);
    const double maxHeight = 500;
    const double maxWidth = 550;

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

    while (index < sortedHighlights.length &&
        sortedHighlights[index].end <= globalStart + result) {
      currentHighlights.add(sortedHighlights[index]);
      highlightCount++;

      if (highlightCount == 5) {
        result = sortedHighlights[index].end - globalStart;
        index++;
        break;
      }

      index++;
    }

    final pageText = text.substring(0, result);
    subParagraphs.add([pageText, currentHighlights]);

    if (text.length == result) break;

    text = text.substring(result);
    globalStart += result;
  }

  return subParagraphs;
}

void downloadPDF(Uint8List bytes) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "notes.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}

class HighlightedRange {
  final String word;
  final int start;
  final int end;
  final Map<String, String> footnoteData;

  HighlightedRange({
    required this.word,
    required this.start,
    required this.end,
    required this.footnoteData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightedRange &&
          runtimeType == other.runtimeType &&
          word.toLowerCase() == other.word.toLowerCase() &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode =>
      word.toLowerCase().hashCode ^ start.hashCode ^ end.hashCode;
}
