import "overlay_helper.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

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
                  child: const Icon(
                    Icons.check,
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
                        color: Colors.white),
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

void exportNotesPopUp(BuildContext context, data) {
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
                  onTap: () async {
                    // await genaratePDF(data);
                    Navigator.pop(context);
                    showSuccessPopup(context);
                   
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
                    // await genaratePDF(data);
                    Navigator.pop(context);
                    showSuccessPopup(context);
                   
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
                    // await genaratePDF(data);
                    Navigator.pop(context);
                    showSuccessPopup(context);
                   
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
