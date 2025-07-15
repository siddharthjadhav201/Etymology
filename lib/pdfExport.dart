
import "dart:typed_data";

import "package:etymology/popUps.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pd;
import "package:universal_html/html.dart" as html;
pd.Container wordData(data){
  return pd.Container(
    child:
    pd.Column(
    crossAxisAlignment: pd.CrossAxisAlignment.start,
    children: [
      pd.Text("${data["word"]}",
      style: pd.TextStyle(fontWeight: pd.FontWeight.bold),),
      pd.Text("${data["description"]}"),
      pd.Text("origin : ${data["origin"]}"),
      pd.Text("prefix : ${data["prefix"]}"),
      pd.Text("suffix : ${data["suffix"]}"),
      pd.SizedBox(height: 20,),
    ]
  ),
  );
  
}

Future genaratePDF(Map data)async{
  final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular-Font.ttf');
final ttf = pd.Font.ttf(fontData);
  final pdf =pd.Document();
  
    pdf.addPage(
    pd.MultiPage(
       theme: pd.ThemeData.withFont(
        base: ttf,
        bold: ttf,
        italic: ttf,
        boldItalic: ttf,
      ),
      pageFormat: PdfPageFormat.a4,
      margin: pd.EdgeInsets.all(20),
      build: (context) {
        List<pd.Widget> widgets = [];
        data.forEach((key, value) {
          widgets.add(
            pd.Container(
              margin: pd.EdgeInsets.only(bottom: 12),
              padding: pd.EdgeInsets.all(10),
              child: pd.Column(
                crossAxisAlignment: pd.CrossAxisAlignment.start,
                children: [
                  pd.Text(value["word"] ?? '',style: pd.TextStyle(font: ttf) ),
                  pd.SizedBox(height: 4),
                  pd.Text("Description: ${value["description"] ?? ''}",style: pd.TextStyle(font: ttf) ),
                  pd.Text("Origin: ${value["origin"] ?? ''}",style: pd.TextStyle(font: ttf) ),
                  pd.Text("Prefix: ${value["prefix"] ?? ''}",style: pd.TextStyle(font: ttf) ),
                  pd.Text("Suffix: ${value["suffix"] ?? ''}",style: pd.TextStyle(font: ttf) ),
                  pd.Text("Definition: ${value["definition"] ?? ''}",style: pd.TextStyle(font: ttf) ),
                ],
              ),
            ),
          );
        });

        return widgets;
      },
    ),
  );
  downloadPDF(await pdf.save());
  // return pdf.save();
            
}

downloadPDF(Uint8List bytes){
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "notes.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}




// Future<Uint8List> genaratePDF(Map data)async{
//   List keys =data.keys.toList();
//   final pdf =pd.Document();
//   pdf.addPage(
//     pd.Page(
//       pageFormat: PdfPageFormat.a4,
//       build:(_)=>
//           pd.Column(
//             crossAxisAlignment: pd.CrossAxisAlignment.start,
//       children: keys.map((key) => wordData(data[key])).toList(),

//     ),
//     ),
//   );

//  return await pdf.save();
  
            
// }