import "dart:developer";

import "package:extended_text_field/extended_text_field.dart";
import "package:flutter/material.dart";
import "package:pdf/pdf.dart";

class Try extends StatefulWidget {
  const Try({super.key});
  @override
  State createState() => _Try();
}

class _Try extends State {
  String text =" ";
  bool isEnabled=false;
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
                int result= getFittingTextForBox(
                    text: controller.text,
                    maxHeight: 700,
                    maxWidth:800,
                    textStyle: textStyle);
                    log("=> $result");
                    log(controller.text.substring(0,result));
                    text=controller.text.substring(0,result);
                    setState(() {
                      isEnabled=true;
                    });
              },
              child: Text("press me")),
              SizedBox(height: 60,),
              
              isEnabled? Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 700,
                  width:800,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text(text,style: textStyle),
                ),
              ) : Text(""),
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
