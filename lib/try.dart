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
  String text = "As a medical student, it is essential to build a solid foundation across multiple medical disciplines, not only to master theoretical knowledge but also to understand how different organ systems interact in complex ways during health and disease. One condition that exemplifies the need for multidisciplinary understanding is anemia, a clinical condition defined by a reduction in the total number of red blood cells (RBCs), hemoglobin concentration, or hematocrit, leading to diminished oxygen-carrying capacity of the blood. Although it may appear to be a hematological issue at first glance, aanemia profoundly affects nearly every organ system and falls within the diagnostic and therapeutic scope of several medical specialties. It is not merely a laboratory finding but a systemic condition with far-reaching consequences. Understanding its implications across disciplines such as cardiology, dermatology, neurology, oncology, hepatology, nephrology, gynecology, radiology, and virology can help future physicians provide more comprehensive care.In cardiology, anemia plays a significant role in both acute and chronic disease presentations. The heart, which relies on a constant supply of oxygen to sustain high metabolic demands, becomes particularly vulnerable when hemoglobin levels are insufficient. Anemia can exacerbate conditions such as heart failure, ischemic heart disease, and arrhythmias by increasing cardiac workload in an attempt to compensate for reduced oxygen delivery. This results in a condition termed high-output heart failure, where cardiac output is increased due to peripheral vasodilation and reduced systemic vascular resistance, commonly seen in chronic severe anemia. Clinically, patients may present with worsening dyspnea, chest pain, tachycardia, or fatigue, often leading cardiologists to perform detailed investigations, including echocardiography and stress testing. Moreover, anemia of chronic disease is frequently observed in patients with longstanding cardiac conditions, indicating a bi-directional relationship. Recognizing anemia early in cardiology settings can prevent hospital readmissions and improve long-term outcomes. Thus, cardiologists must be proficient in interpreting complete blood counts (CBC), iron studies, and reticulocyte indices, and collaborate with hematologists when necessary.In dermatology, anemia can manifest in subtle yet diagnostically valuable skin changes. One of the most classic signs is pallor, especially noticeable in areas where capillaries are close to the surface, such as the nail beds, palmar creases, and conjunctiva. Iron-deficiency anemia can also lead to koilonychia (spoon-shaped nails), pruritus, angular cheilitis, and glossitis, all of which offer important clinical clues. Certain chronic skin disorders such as lichen planus, eczema, or psoriasis may flare up or worsen in anemic states due to impaired immune function and poor tissue oxygenation. Furthermore, vitamin deficiencies—particularly vitamin B12 and folate—can produce hyperpigmentation, vitiligo, or seborrheic dermatitis-like rashes. Dermatologists need to consider systemic causes like anemia when treating recurrent or unresponsive dermatologic conditions, especially in malnourished, elderly, or menstruating female patients. Identifying these signs early can prompt referral for further evaluation and appropriate management, demonstrating how dermatological examination is often the first step toward diagnosing systemic illness.The impact of anemia on the nervous system is equally significant, making it a crucial concern in neurology. The brain, highly sensitive to oxygen deprivation, can exhibit a wide range of symptoms when anemia is present. These include headaches, dizziness, fatigue, poor concentration, cognitive decline, syncope, and memory loss. In severe or chronic cases, hypoxia-induced encephalopathy may develop. Iron-deficiency anemia has been particularly "; 
  bool isEnabled = false;
  TextEditingController controller = TextEditingController();
  TextStyle textStyle = TextStyle(
  fontSize: 12,
  // letterSpacing: -0.0142,
  letterSpacing: 0,
  // fontWeight: FontWeight.w900, // equivalent to pw.FontWeight.normal
  // wordSpacing: 1.65,
  wordSpacing: 1.5,
  height: 1.3,
  fontFamily: "NotoSans" // approximated line spacing to line height ratio // required if used outside Material widgets
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
              height: 775,
              width: PdfPageFormat.a4.width-100,
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
                    maxHeight: 775,
                    maxWidth: PdfPageFormat.a4.width-100,
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

          // isEnabled

          true
              ? Center(
                  child: Column(
                    children: [
                      Container(
                        // padding: EdgeInsets.only(),
                        // margin: EdgeInsets.all(20),
                        height: 700,
                        width:PdfPageFormat.a4.width-100.toInt(),
                        // decoration: BoxDecoration(border: Border.all()),
                        child: RichText(text: TextSpan(text: text,style: textStyle))
                        // Text(text, style: textStyle),
                      ),
                      Text("${PdfPageFormat.a4.width-100}") // 495.27559055118104
                    ],
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
