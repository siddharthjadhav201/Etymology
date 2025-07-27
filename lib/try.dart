import "dart:developer";

import "package:extended_text_field/extended_text_field.dart";
import "package:flutter/material.dart";
import "package:pdf/pdf.dart";
// import "package:pdf/pdf.dart";
import 'package:pdf/widgets.dart' as pd;

class Try extends StatefulWidget {
  const Try({super.key});
  @override
  State createState() => _Try();
}

class _Try extends State {
  String text = " ";
  bool isEnabled = false;
  TextEditingController controller = TextEditingController();
  TextStyle textStyle = TextStyle(
    fontSize: 14,
    letterSpacing: 0.8,
    height: 1.2, // control line height explicitly
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all()),
              height: 600,
              width: 700,
              child: ExtendedTextField(
                style: textStyle,
                expands: true,
                maxLines: null,
                controller: controller,
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                int result = getFittingTextForBox(
                    text: controller.text,
                    maxHeight: 700,
                    maxWidth: 800,
                    textStyle: textStyle);
                log("=> $result");
                log(controller.text.substring(0, result));
                text = controller.text.substring(0, result);
                setState(() {
                  isEnabled = true;
                });
              },
              child: Text("press me")),
          SizedBox(
            height: 60,
          ),
          isEnabled
              ? Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    height: 700,
                    width: 800,
                    decoration: BoxDecoration(border: Border.all()),
                    child: Text(text, style: textStyle),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }
}

int getFittingTextForBox({
  required String text,
  required double maxWidth,
  required double maxHeight,
  required TextStyle textStyle,
}) {
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
    maxLines: null,
  );

  int start = 0;
  int end = text.length;
  int resultIndex = 0;

  while (start <= end) {
    final mid = (start + end) ~/ 2;
    final candidate = text.substring(0, mid);

    textPainter.text = TextSpan(text: candidate, style: textStyle);
    textPainter.layout(maxWidth: maxWidth);

    if (textPainter.height <= maxHeight) {
      resultIndex = mid;
      start = mid + 1;
    } else {
      end = mid - 1;
    }
  }
  return resultIndex;
}


int getFittingCharCountPdf({
  required String text,
  required double maxWidth,
  required double maxHeight,
  required pd.Font font,
  double fontSize = 12,
  double wordSpacing = 1.5,
  double lineSpacing = 2,
}) {
  try {
    pd.TextStyle style = pd.TextStyle(
      font: font,
      fontSize: fontSize,
      wordSpacing: wordSpacing,
      lineSpacing: lineSpacing,
    );

    int low = 0;
    int high = text.length;
    int result = 0;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      String subText = text.substring(0, mid);

      final span = pd.TextSpan(text: subText, style: style);
      final rt = pd.RichText(text: span);
      log("^^^1");
      final doc = PdfDocument();
      final context = pd.Context(document: doc);

      final constraints = pd.BoxConstraints(maxWidth: maxWidth);

// Layout the widget and get the result context
      //  rt.layout(context, constraints);
      // rt.layout(pd.Context(document: PdfDocument()),
      //     pd.BoxConstraints(maxWidth: maxWidth));
      log("^^^2");
      final height = rt.box!.height;
      if (height <= maxHeight){
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  } catch (e) {
    log("error in getFittingCharCountPdf");
    log("$e");
  }
  return -1;
}
