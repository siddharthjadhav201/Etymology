
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
  List keys =data.keys.toList();
  final pdf =pd.Document();
  pdf.addPage(
    pd.Page(
      pageFormat: PdfPageFormat.a4,
      build:(_)=>
          pd.Column(
            crossAxisAlignment: pd.CrossAxisAlignment.start,
      children: keys.map((key) => wordData(data[key])).toList(),

    ),
    ),
  );

  var byte=await pdf.save();
   final blob = html.Blob([byte], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "etymo_notes.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
            
}

