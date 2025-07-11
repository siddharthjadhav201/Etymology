
import "dart:typed_data";

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

Future<Uint8List> genaratePDF(Map data)async{
  final pdf =pd.Document(title: "etymo");
  
    pdf.addPage(
    pd.MultiPage(
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
                  pd.Text(value["word"] ?? '',
                      style: pd.TextStyle(
                           fontWeight: pd.FontWeight.bold)),
                  pd.SizedBox(height: 4),
                  pd.Text("Description: ${value["description"] ?? ''}"),
                  pd.Text("Origin: ${value["origin"] ?? ''}"),
                  pd.Text("Prefix: ${value["prefix"] ?? ''}"),
                  pd.Text("Suffix: ${value["suffix"] ?? ''}"),
                  pd.Text("Definition: ${value["definition"] ?? ''}"),
                ],
              ),
            ),
          );
        });

        return widgets;
      },
    ),
  );

  return pdf.save();
            
}

downloadPDF(Uint8List byte){

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