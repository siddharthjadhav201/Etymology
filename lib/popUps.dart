import "dart:developer";

import "package:etymology/highlight_block_formatter.dart";
import "package:etymology/pdfExport.dart";
import "package:etymology/providers.dart";
import "package:etymology/services/remote_services.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";

void showCenterPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

void showSuccessPopup(BuildContext context) {
  // double width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    barrierDismissible: false, // user can't close it manually
    builder: (context) {
      // Auto-close after 2 seconds
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pop(true);
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(255, 73, 242, 144)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22),
            height: 100,
            // width: 450,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: Colors.green),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                     color: Color.fromARGB(76, 217, 217, 217)),
                     child: const Icon(Icons.check,
                    color: Colors.white,
                  ),
                ),
              
                
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    "PDF Downloaded Successfully",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showLimitedAccessPopup(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.0078)),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.all(width * 0.013),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.0078),
              color: const Color(0xFFFF9800)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.0143, vertical: width * 0.013),
            constraints: BoxConstraints(minHeight: width * 0.0651),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.0078), 
                color: const Color(0xFFFF9800)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: width * 0.0326,
                  width: width * 0.0326,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(76, 255, 255, 255)),
                  child: Icon(Icons.lock_outline,
                    color: Colors.white,
                    size: width * 0.0208,
                  ),
                ),
                SizedBox(width: width * 0.0104),
                Flexible(
                  child: Text(
                    "This function is currently not available for you due to limited access",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.0163,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: width * 0.01, right: width * 0.013, top: width * 0.01),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.0208, vertical: width * 0.0065),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.0052),
              ),
            ),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: width * 0.0163,
                color: Colors.black
              ),
            ),
          ),
        ],
      );
    },
  );
}

// void notePreviewPopUp(BuildContext context, Map data ) {
// List keys =data.keys.toList();
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       contentPadding: EdgeInsets.only(top:10),
//       content: SizedBox(
//         height: MediaQuery.of(context).size.height*0.8,
//         width: MediaQuery.of(context).size.width*0.6,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: (){
//                       Navigator.pop(context);
//                     },
//                     child: Icon(Icons.arrow_back)),
//                     SizedBox(width:10),
//                   Text("Note Preview",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Spacer(),
//                   ElevatedButton(
//                     onPressed: (){
//                       Navigator.pop(context);
//                       exportNotesPopUp(context,data);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStatePropertyAll(const Color(0xFF363BBA)),
//                     ),
//                    child: Row(
//                     children: [
//                       Icon(Icons.download_rounded,color: Colors.white,),
//                       Text("Export",
//                       style:TextStyle(
//                         color: Colors.white,
//                       ) ,),
//                     ],
//                    ),
//                    )
//                 ],
//               ),
//             ),
//             Divider(),
//             Spacer(),
//             Container(
//               padding: EdgeInsets.all(10),
//               height: MediaQuery.of(context).size.height*0.65,
//         width: MediaQuery.of(context).size.width*0.45,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//                 borderRadius: BorderRadius.all(Radius.circular(10))
//               ),
//               child: ListView.builder(
//                             itemCount:data.length,
//                             itemBuilder:
//                           (context,index){
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("${data[keys[index]]["word"]}",
//                               style: TextStyle(fontWeight: FontWeight.w900),),
//                                 Text("${data[keys[index]]["description"]}"),
//                                 Text("origin : ${data[keys[index]]["origin"]}"),
//                                 Text("prefix : ${data[keys[index]]["prefix"]}"),
//                                 Text("suffix : ${data[keys[index]]["suffix"]}"),
//                                 SizedBox(height: 20,),
//                               ],
//                             );
//                           }
//                           ),

//             ),
//             Spacer(),
//           ],
//         ),
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

//     ),
//   );
// }

void exportNotesPopUp(BuildContext context, data, String paragraph) {
  double width = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: width * 0.3,
        width: width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          children: [
             Padding(
              padding: EdgeInsets.only(left: width*0.007, top: width*0.009 ),
               child: Row(
                  children: [
                    SizedBox(height: width*0.03, width: width*0.01,),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_outlined)),
                        SizedBox(height: width*0.03, width: width*0.01,),
                       Text(
                        "Export Notes",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, 
                            fontSize: width * 0.016,
                            
                            ),
                      ),
                    
                  ],
                ),
             ),
            
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: width*0.02 , top: width*0.012),
              child: Text(
                  "Export your annotated notes as a PDF file, Word document, or shareable link",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: width* 0.016,
                    color: Colors.grey.shade600,
                  ),),
            ),
            SizedBox(height: width* 0.033,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                   onTap: ()async {
                    HighlightProvider highlightProvider= context.read<HighlightProvider>();
                    List<HighlightedRange> highlightedWordRange=highlightProvider.highlightedRanges;
                    Map highlightWordsData=highlightProvider.highlightWordsData;
                    List<String> words= highlightProvider.highlightedWords;
                   await genaratePDF(paragraph,highlightedWordRange,highlightWordsData,words);
                   Navigator.pop(context);
                    showSuccessPopup(context);
                    // pdfPreviewPopUp(context,data);
                  },
                  child: Container(
                    height: width*0.11,
                    width: width*0.1,
                    padding: EdgeInsets.symmetric(vertical: width*0.007, horizontal: width*0.01 ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey , width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width*0.06,
                          child: Image.asset("assets/pdf.png",
                          fit: BoxFit.cover,),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text("PDF",
                        style: GoogleFonts.poppins(
                          fontSize: width*0.016,
                          fontWeight: FontWeight.w400,

                        ),),
                        
                      ],
                    ),
                  ),
                ),
              
               GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    showLimitedAccessPopup(context);
                   
                  },
                  child: Container(
                    height: width*0.11,
                    width: width*0.1,
                    padding: EdgeInsets.symmetric(vertical: width*0.007, horizontal: width*0.01 ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey , width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width*0.06,
                          child: Image.asset("assets/word.png",
                          fit: BoxFit.cover,),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text("Word",
                        style: GoogleFonts.poppins(
                          fontSize: width*0.016,
                          fontWeight: FontWeight.w400,

                        ),),
                        
                      ],
                    ),
                  ),
                ),
              
               GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    showLimitedAccessPopup(context);
                   
                  },
                  child: Container(
                    height: width*0.11,
                    width: width*0.1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey , width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width*0.06,
                          child: Image.asset("assets/share_link.png",
                          fit: BoxFit.cover,),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text("Share Link",
                        style: GoogleFonts.poppins(
                          fontSize: width*0.016,
                          fontWeight: FontWeight.w400,

                        ),),
                        
                      ],
                    ),
                  ),
                ),
              
              ],
            ),
            
            Spacer()
          ],
        ),
      ),
    ),
  );
}


// void pdfPreviewPopUp(BuildContext context, data) {
//   print(data);
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       contentPadding: EdgeInsets.all(0),
//       content: SizedBox(
//         height: MediaQuery.of(context).size.height * 0.8,
//         width: MediaQuery.of(context).size.width * 0.6,
//         child: PdfPreview(
//           build: (format) => genaratePDF(data),
//         ),
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   );
// }

// void showPopupAtFixedPosition(
//     BuildContext context, Offset position, Map info) {
//     HighlightProvider highlightProvider= context.read<HighlightProvider>();
//   final entry = OverlayEntry(
//     builder: (context) => Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: Material(
//         child: Container(
//           width: 145,
//           height: 160,
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black)],
//           ),
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title (Medical_Term)
//                 Row(
//                   children: [
//                     // Image.asset("assets/medical_term_sign.png",
//                     // width: 18,
//                     // height: 18,),
//                     Expanded(
//                       child: Text(
//                         info['word'] ?? '',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             fontFamily: 'Roboto'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
          
//                 // Description (Term_Des)
//                 Text(
//                   info['description'] ?? '',
//                   style: TextStyle(fontSize: 10),
//                 ),
          
//                 const Divider(height: 20, thickness: 1),
          
//                 // Origin
//                 if (info['origin'] != null)
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: Colors.black, fontSize: 10),
//                       children: [
//                         TextSpan(
//                           text: "Origin : ",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         TextSpan(text: info['origin']),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(height: 4),
          
//                 // Prefix
//                 if (info['prefix'] != null)
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: Colors.black, fontSize: 10),
//                       children: [
//                         TextSpan(
//                           text: "Prefix : ",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         TextSpan(text: info['prefix']),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(height: 4),
          
//                 if (info['suffix'] != null)
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: Colors.black, fontSize: 10),
//                       children: [
//                         TextSpan(
//                           text: "Suffix : ",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         TextSpan(text: info['suffix']),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//         ),
//       ),
//     ),
//   );
//    highlightProvider.insertOverlay(entry, context);
//    log(context.read<HighlightProvider>().overlay.toString());

//   // Auto-close after 2 seconds
//   Future.delayed(Duration(seconds: 4), () => entry.remove());
// }


