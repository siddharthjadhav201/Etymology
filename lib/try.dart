import "dart:developer";

import "package:etymology/grammaticalwordpage.dart";
import "package:etymology/navbar.dart";
import "package:etymology/services/remote_services.dart";
import "package:flutter/material.dart";
// import "package:http/http.dart";
import "package:provider/provider.dart";
import "providers.dart";
import 'package:google_fonts/google_fonts.dart';
import 'highlight_spanbuilder.dart';
import 'package:extended_text_field/extended_text_field.dart';

class NotesEditor extends StatefulWidget {
  @override
  _NotesEditorState createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {
  final TextEditingController controller = TextEditingController();
  final UndoHistoryController undoController= UndoHistoryController();
  TextSelection? previousSelection;
  bool _limitPopupShown = false;
  // int _charCount = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller.addListener(() {
  //     setState(() {
  //       _charCount = _controller.text.length;
  //     });
  //   });
  // }



  @override
void initState() {
  super.initState();

  controller.addListener(() {
    if (controller.text.length >= 5000 && !_limitPopupShown) {
      _limitPopupShown = true;
      showCenterPopup(context, "You have reached the character limit.");
    }

    if (controller.text.length < 5000) {
      _limitPopupShown = false; 
    }
    final currentSelection = controller.selection;
      if (previousSelection != currentSelection && currentSelection.isValid) {
        print("Previous Selection: $previousSelection");
        print("Current Selection: $currentSelection");
        previousSelection = currentSelection;
      }
  });
}
  bool isAlphanumeric(String char) {
    return RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
  }

  bool isSymbol(String char) {
    return !RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
  }

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

  void _highlightSelection() {
    log("${controller.selection.start}  ,  ${controller.selection.end}");
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;
    int start = 0;
    int end = 0;
    start = text[selection.start] == " " || isSymbol(text[selection.start])
        ? selection.start + 1
        : selection.start;
    end = text[selection.end] == " " || isSymbol(text[selection.end])
        ? selection.end - 1
        : end = selection.end - 2;

    if (start == 0
        ? false
        : isAlphanumeric(text[start - 1]) || end == text.length
            ? false
            : isAlphanumeric(text[end + 1])) {
      return;
    } else {
      final selectedWord =
          text.substring(selection.start, selection.end).trim();
      if (selectedWord.isEmpty || selectedWord.contains(" ")) return;

if (context.read<HighlightProvider>().isGrammatical(selectedWord)) {
  showCenterPopup(context, "⚠️ '$selectedWord' is a grammatical word and cannot be highlighted.");
  return;
}

      final success = context
          .read<HighlightProvider>()
          .toggleHighlight(selectedWord, start, end);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can highlight up to 10 words only.")),
        );
      }
    }
  }

  void updateLocations() {
    HighlightProvider highlightProvider = context.read<HighlightProvider>();
    List highlightedWordsLocations = highlightProvider.highlightedWordLocations.map((element){return element;}).toList();
    int diff = controller.text.length - highlightProvider.prevTextLength;

      for (List highlightedWordsLocation in highlightedWordsLocations){
       if( highlightedWordsLocation[0] > previousSelection!.start){
        highlightedWordsLocation[0]=highlightedWordsLocation[0]+diff;
        highlightedWordsLocation[1]=highlightedWordsLocation[1]+diff;
       }
         
      }
    

    highlightProvider.setPrevTextLength(controller.text.length);
  }
  

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final highlightProvider = Provider.of<HighlightProvider>(context);
    return Scaffold(
        body: ListView(
      children: [
        CustomNavbar(),
        Padding(
          padding: EdgeInsets.only(top: width*0.038, right: width*0.09, left: width*0.09),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(width*0.017),
                width: width*0.665,
                height: width*0.057,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/i.png",
                      height: width*0.019 ,
                    ),
                    SizedBox(
                      width: width*0.017,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                              fontSize: width*0.0138, color: Colors.black),
                          children: [
                            TextSpan(text: 'Paste your study notes and click '),
                            TextSpan(
                              text: '‘Annotate’',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                                text:
                                    ' to see enriched etymological meanings.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
               SizedBox(
                height: width*0.019,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: width*0.033,
                      width: width*0.0861,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // color: Color.fromARGB(1, 255, 255, 255),
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 166, 166, 166),
                          )),
                      child: Text('Paste',
                          style: GoogleFonts.poppins(
                              letterSpacing: 0.08,
                              fontSize: width*0.0166,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _highlightSelection();
                    },
                    child: Container(
                        height: width*0.033,
                        width: width*0.125,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            // color: Color.fromARGB(1, 255, 255, 255),
                            border: Border.all(
                              width: 1,
                              color: Color.fromARGB(255, 166, 166, 166),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/brush-square.png",
                              height: width*0.0305,
                              width: width*0.0305,
                            ),
                            SizedBox(
                              width: width*0.0069,
                            ),
                            Text('Highlight',
                                style: GoogleFonts.poppins(
                                    letterSpacing: 0.08,
                                    fontSize: width*0.0166,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                          ],
                        )),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      highlightProvider.clear();},
                    child: Container(
                      height: width*0.033,
                      width: width*0.1,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // color: Color.fromARGB(1, 255, 255, 255),
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 166, 166, 166),
                          )),
                      child: Text('Clear All',
                          style: GoogleFonts.poppins(
                              letterSpacing: 0.08,
                              fontSize: width*0.0166,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    ),
                  ),
                   SizedBox(
                    width: width*0.0194,
                  )
                ],
              ),
               SizedBox(
                height: width*0.02,
              ),
              Container(
                height: width*0.263,
                width: width*0.805,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1,
                      color: Color.fromARGB(255, 166, 166, 166),
                    )),
                alignment: Alignment.topLeft,
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(
                    selectionColor: Colors.blue,
                  ),
                  child: ExtendedTextField(
                    onChanged: (string) {
                      updateLocations();
                    },
                    undoController: undoController,
                    controller: controller,
                    expands: true,
                    maxLines: null,
                    specialTextSpanBuilder:
                        HighlightSpanBuilder(highlightProvider),
                    decoration: InputDecoration.collapsed(
                        hintText: "Type and select words to highlight"),
                  ),
                ),
              ),
               SizedBox(
                height: width*0.0194,
              ),
              GestureDetector(
                onTap: () {
                  getWordInfo(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        height: width*0.033,
                        width: width*0.125,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 54, 59, 186),
                            borderRadius: BorderRadius.circular(8),
                            // color: Color.fromARGB(1, 255, 255, 255),
                            border: Border.all(
                              width: 1,
                              color: Color.fromARGB(255, 166, 166, 166),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image.asset(
                            //   "assets/magicpen.png",
                            //   height: 30,
                            //   width: 30,
                            // ),
                            SizedBox(
                              width: width*0.0069,
                            ),
                            Text('Annotate',
                                style: GoogleFonts.poppins(
                                    letterSpacing: 0.08,
                                    fontSize: width*0.0166,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        )),
                  ],
                ),
              ),

              //annotate box
              highlightProvider.highlightWordsData.isEmpty?
              const Text(""):

              Column(
                children: [
                   SizedBox(height: width*0.0194,),
                  Container(
                    padding: EdgeInsets.all(10),
                    height: width*0.2638,
                    width: width*0.805,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: Color.fromARGB(255, 166, 166, 166),
                        )),
                    alignment: Alignment.topLeft,
                    child: TextSelectionTheme(
                      data: TextSelectionThemeData(
                        selectionColor: Colors.blue,
                      ),
                      child: ListView.builder(
                        itemCount: highlightProvider.highlightWordsData.length,
                        itemBuilder:
                      (context,index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("name : ${highlightProvider.highlightWordsData[index]["name"]}",
                          style: TextStyle(fontWeight: FontWeight.w900),),
                            Text(highlightProvider.highlightWordsData[index]["description"]),
                            SizedBox(height: 0.0138,),
                          ],
                        );
                      }
                      ),
                    ),
                  ),
                ],
              ),



               SizedBox(
                height: 0.0138,
              ),


              // Wrap(
              //   children: highlightProvider.highlightedWords
              //       .map((word) => Chip(label: Text(word)))
              //       .toList(),
              // ),
               SizedBox(height: 0.0207),
//               GestureDetector(
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => GrammarWordsPage()),
//     );
//   },
//   child: Container(
//     margin: const EdgeInsets.only(top: 20),
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     decoration: BoxDecoration(
//       color: Colors.green,
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Text(
//       'Show Highlighted Words',
//       style: TextStyle(color: Colors.white, fontSize: 18),
//     ),
//   ),
// ),
 

            ],
          ),
        ),
      ], 
    ));
  }
}
