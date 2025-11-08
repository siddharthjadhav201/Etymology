
import "dart:developer";
import "package:etymology/highlight_block_formatter.dart";
import "package:etymology/pdfStructure.dart";
import "package:etymology/popUps.dart";
import "package:etymology/providers.dart";
import "package:etymology/services/remote_services.dart";
import "package:etymology/string_functions.dart";
import "package:etymology/try.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pd;
import "package:supabase_flutter/supabase_flutter.dart";
import "package:universal_html/html.dart" as html;


List<pd.InlineSpan> paragraphColumn(item,pd.Font ttf){
  pd.TextStyle textStyle=pd.TextStyle(
    font:ttf,
    // font:pd.Font(),
    fontSize: 12,
    wordSpacing: 1.5,
    lineSpacing: 2,
    letterSpacing: 0,
    fontWeight: pd.FontWeight.normal
  );
  try{
  String data=item[0];
  int startPosition=item[3];
  List highlightedWordsLocations=item[1];
  List<pd.InlineSpan> children=[];
  int globalStartPage=0;
  for(HighlightedRange highlightedWordsLocation in highlightedWordsLocations){
    children.add(pd.TextSpan(
      text: data.substring(globalStartPage ,highlightedWordsLocation.start-startPosition),
      style:textStyle
    ));
    children.add(pd.TextSpan(
      text: data.substring(highlightedWordsLocation.start-startPosition,highlightedWordsLocation.end-startPosition),
      style: textStyle.copyWith(
         background: pd.BoxDecoration(color: PdfColor.fromHex("#FFC107")),
      )
    ),
    );
    globalStartPage=highlightedWordsLocation.end-startPosition;
  }
  children.add(pd.TextSpan(
      text: data.substring(globalStartPage),
      style:textStyle,
    ));
return children;
  } catch(e){
    log("error in  paragraphColumn $e");
    return [];
  }
}

pd.Container wordData(data){
  pd.TextStyle textStyle =pd.TextStyle(
    fontSize: 8,
  );

  log("####$data");
  if(data==null){
    return pd.Container();
  }else{
     return pd.Container(
      decoration: pd.BoxDecoration(
        // border: pd.Border.all()
      ),
      height: 80,
    child:
    pd.Row(
      mainAxisAlignment: pd.MainAxisAlignment.start,
      children: [
        pd.Column(
    crossAxisAlignment: pd.CrossAxisAlignment.start,
    children: [
      pd.Text("${data["medical_term"]}",
      style: pd.TextStyle(
        fontSize:9,
        fontWeight: pd.FontWeight.bold),),
        pd.SizedBox(width: PdfPageFormat.a4.width-100.toInt(), child: pd.Text("${data["meaning"]}",style: textStyle),),
      
      // pd.Text("origin : ${data["origin"]}",style: textStyle),
      // pd.Text("prefix : ${data["prefix"]}",style: textStyle),
      // pd.Text("suffix : ${data["suffix"]}",style: textStyle),
    ]
  ),
      ]
    ),
  );
  } 
}
Future genaratePDF(String paragraph,List<HighlightedRange> highlightedWords,Map highlightWordsData,List words)async{
  print(highlightWordsData);
  final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular-Font.ttf');
  final ttf = pd.Font.ttf(fontData);
  final pdf =pd.Document();
    // theme: pd.ThemeData.withFont(
    //   base: ttf,
    //   bold: ttf,
    //   italic: ttf,
    //   boldItalic: ttf,
    // ),);
    pdf.addPage(
    pd.MultiPage(
      margin:pd.EdgeInsets.only(left: 50,right: 50,top:50,bottom: 0),
      pageFormat: PdfPageFormat.a4,
      // margin: pd.EdgeInsets.all(20),
      build: (context){
        log("width a4 : ${PdfPageFormat.a4.width-100}");
        List<List> subParagraph=getFittingText1(text:paragraph,highlightedWords:highlightedWords,width:PdfPageFormat.a4.width-100);
        List<pd.Widget> widgets = [];
        for(List item in subParagraph){
          widgets.add(
            pd.Column(
              crossAxisAlignment: pd.CrossAxisAlignment.start,
              children: [
                 pd.Container(
                  // decoration: pd.BoxDecoration(
                  //   border: pd.Border.all()
                  //   ),
                  // alignment: pd.Alignment.topLeft,
              height: item[2],
              width: PdfPageFormat.a4.width-100.toInt(),
              child: pd.RichText(text: pd.TextSpan(
                children: paragraphColumn(item,ttf)
              )),
            ),
             item[1].length!=0? pd.Padding(padding: pd.EdgeInsets.symmetric(vertical: 15 ),child: pd.Divider()) : pd.Text(""),
              ],
            ),);

            widgets.add( pd.Container(
              child: pd.Column(
                children: List.generate(item[1].length, (index){
                  // return pd.Text(item[1][index].word);
                  return wordData(highlightWordsData[item[1][index].word]??{"medical_term":item[1][index].word,"description":"-------------","origin":"-----------","prefix":"------","suffix":"------"});
                })
              ),
            )
           
          );
        }

        return widgets;
      },
    ),
  );
  downloadPDF(await pdf.save());
  String? pdfUrl= await uploadPdfToSupabase(await pdf.save());
  final supabase = Supabase.instance.client;

  try {
    await supabase.from('tbl_pdf_data').insert({
      'pdf_url': pdfUrl,
      'col_highlighted_words':words
    });
  }
  catch(e){
    print(e);
  }
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


void storePDFData(){
  try{

  }catch(e){

  }
}


