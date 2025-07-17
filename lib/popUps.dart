import "package:etymology/pdfExport.dart";
import "package:etymology/pdfPreview.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:printing/printing.dart";

void showCenterPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
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

void exportNotesPopUp(BuildContext context, data) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.only(top: 10),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width * 0.45,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
              
                      },
                      child: Icon(Icons.arrow_back)),
                  SizedBox(width: 10),
                  Text(
                    "Export Notes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                  "Export your annotated notes as a PDF file, Word document, or shareable link"),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: ()async {
                   await genaratePDF(data);
                   Navigator.pop(context);
                    showSuccessPopup(context);
                    // pdfPreviewPopUp(context,data);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4 / 3,
                    width: MediaQuery.of(context).size.height * 0.4 / 3,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text("PDF")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

void showPopupAtFixedPosition(
    BuildContext context, Offset position, String text) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(text, style: TextStyle(fontSize: 16)),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // Auto-close after 2 seconds
  Future.delayed(Duration(seconds: 2), () => entry.remove());
}
