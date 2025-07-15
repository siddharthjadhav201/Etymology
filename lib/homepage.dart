import "dart:developer";

// import "package:etymology/grammaticalwordpage.dart";
import "package:etymology/pdfExport.dart";
import "package:etymology/highlight_block_formatter.dart";
import "package:etymology/navbar.dart";
import "package:etymology/popUps.dart";
import "package:etymology/services/remote_services.dart";
import "package:etymology/string_functions.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
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
  bool _limitPopupShown = false;
  
  TextEditingController noteController = TextEditingController();
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

    var highlightProvider = context.read<HighlightProvider>();
    highlightProvider.noteController = noteController;
    highlightProvider.homeScreenContext = context;
    noteController.addListener(() {
      if (noteController.text.length >= 5000 && !_limitPopupShown) {
        _limitPopupShown = true;
        showCenterPopup(context, "You have reached the character limit.");
      }

      if (noteController.text.length < 5000) {
        _limitPopupShown = false;
      }
    });
  }

  void _highlightSelection() {
    var highlightProvider = context.read<HighlightProvider>();
    log("${noteController.selection.start}  ,  ${noteController.selection.end}");
    final text = noteController.text;
    if (!noteController.selection.isValid ||
        noteController.selection.isCollapsed) return;
    final selection = adjustSelection(
        noteController.selection, highlightProvider.highlightedRanges);
    int start = 0;
    int end = 0;
    start = text[selection.start] == " " || isSymbol(text[selection.start])
        ? selection.start + 1
        : selection.start;
    end = text[selection.end - 1] == " " || isSymbol(text[selection.end - 1])
        ? selection.end - 2
        : end = selection.end - 1;
    if (start > end) {
      log("1");
      return;
    }
    if (start == 0
        ? false
        : isAlphanumeric(text[start - 1])
            ? true
            : end == text.length - 1
                ? false
                : isAlphanumeric(text[end + 1])) {
      log("2");
      return;
    } else {
      final selectedWord =
          text.substring(selection.start, selection.end).trim().toLowerCase();

      if (selectedWord.isEmpty ||
          selectedWord.contains(" ") ||
          containsSymbol(selectedWord)) {
        log("3");
        return;
      }

      if (highlightProvider.isGrammatical(selectedWord)) {
        showCenterPopup(context,
            "⚠️ '$selectedWord' is not a scientific term and cannot be highlighted.");
        return;
      }
      final success =
          highlightProvider.toggleHighlight(selectedWord, start, end + 1);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can highlight up to 10 words only.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final highlightProvider = Provider.of<HighlightProvider>(context);
    return Scaffold(
        body: Stack(
      children: [
        ListView(
          children: [
            CustomNavbar(),
            Padding(
              padding: EdgeInsets.only(
                  top: width * 0.038, right: width * 0.09, left: width * 0.09),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(width * 0.017),
                    // width: width * 0.665,
                    height: width * 0.057,
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
                          height: width * 0.019,
                        ),
                        SizedBox(
                          width: width * 0.017,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                  fontSize: width * 0.0138,
                                  color: Colors.black),
                              children: [
                                TextSpan(
                                    text: 'Paste your study notes and click '),
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
                    height: width * 0.019,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: width * 0.033,
                          width: width * 0.0861,
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
                                  fontSize: width * 0.0166,
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
                            height: width * 0.033,
                            width: width * 0.125,
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
                                  height: width * 0.0305,
                                  width: width * 0.0305,
                                ),
                                SizedBox(
                                  width: width * 0.0069,
                                ),
                                Text('Highlight',
                                    style: GoogleFonts.poppins(
                                        letterSpacing: 0.08,
                                        fontSize: width * 0.0166,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black)),
                              ],
                            )),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          highlightProvider.clear();
                        },
                        child: Container(
                          height: width * 0.033,
                          width: width * 0.1,
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
                                  fontSize: width * 0.0166,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: width * 0.02,
                  ),
                  Container(
                    height: highlightProvider.isAnnotated ? width * 0.263 / 2 : width * 0.263,
                    // width: width * 0.805,
                    padding: EdgeInsets.all(10),
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
                        style: TextStyle(fontSize: 15),
                        inputFormatters: [
                          HighlightBlockFormatter(
                              highlightProvider.highlightedRanges, context)
                        ],
                        controller: noteController,
                        expands: true,
                        maxLines: null,
                        specialTextSpanBuilder:
                            HighlightSpanBuilder(highlightProvider, context),
                        decoration: InputDecoration.collapsed(
                            hintText: "Type and select words to highlight"),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: width * 0.0194,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(highlightProvider.highlightedWords.isNotEmpty){
                            highlightProvider.setAnnotatedStatus(true);
                          annotate(context);
                          }
                          
                        },
                        child: Container(
                            height: width * 0.033,
                            width: width * 0.125,
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
                                SizedBox(
                                  width: width * 0.0069,
                                ),
                                Text('Annotate',
                                    style: GoogleFonts.poppins(
                                        letterSpacing: 0.08,
                                        fontSize: width * 0.0166,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ],
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: width * 0.0194,
                  ),

                  //annotate box
                  !highlightProvider.isAnnotated
                      ? const Text("")
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  // margin: EdgeInsets.only(left: 00),
                                  padding: EdgeInsets.all(20),
                                  height: width * 0.2638 / 2,
                                  width: width * 0.82,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        width: 1,
                                        color:
                                            Color.fromARGB(255, 166, 166, 166),
                                      )),
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      itemCount: highlightProvider
                                          .highlightWordsData.keys.length,
                                      itemBuilder: (context, index) {
                                        Map highlightWordsData =
                                            highlightProvider
                                                .highlightWordsData;
                                        List keys =
                                            highlightWordsData.keys.toList();

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${highlightProvider.highlightWordsData[keys[index]]["word"]}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900),
                                            ),
                                            Text(
                                                "${highlightProvider.highlightWordsData[keys[index]]["description"]}"),
                                            Text(
                                                "origin : ${highlightProvider.highlightWordsData[keys[index]]["origin"]}"),
                                            Text(
                                                "prefix : ${highlightProvider.highlightWordsData[keys[index]]["prefix"]}"),
                                            Text(
                                                "suffix : ${highlightProvider.highlightWordsData[keys[index]]["suffix"]}"),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: width * 0.0194,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                     highlightProvider.setAnnotatedStatus(false);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: width * 0.033 * 0.75,
                                    width: width * 0.1073,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color:
                                              Color.fromARGB(255, 166, 166, 166),
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Image.asset("assets/edit.png",height: 32,width: 32,),
                                        Text("Edit Note Again",
                                            style: GoogleFonts.poppins(
                                              letterSpacing: 0.08,
                                              fontSize: width * 0.010,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                     
                                    if (highlightProvider
                                        .highlightWordsData.isNotEmpty) {
                                     exportNotesPopUp(context,highlightProvider.highlightWordsData);
                                          
                                    }
                                  },
                                  child: Container(
                                    height: width * 0.033 * 0.75,
                                    width: width * 0.0616,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 166, 166, 166),
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Image.asset("assets/edit.png",height: 32,width: 32,),
                                        Text("Export",
                                            style: GoogleFonts.poppins(
                                              letterSpacing: 0.08,
                                              fontSize: width * 0.010,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: width * 0.0194,
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
                  //  SizedBox(height: 0.0207),
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
        ),
        // Stack(
        //   children: List.generate(context.read<HighlightProvider>().activePopUpInfo.length, (index){
        //     Size sceenSize=MediaQuery.of(context).size;
        //     var hightlightProvider=context.read<HighlightProvider>();
        //     List words=hightlightProvider.activePopUpInfo.keys.toList();
        //     List positions=hightlightProvider.activePopUpInfo.values.toList();
        //    return Positioned(
        //     top:positions[index][1]*sceenSize.height,
        //     left:positions[index][0]*sceenSize.width,
        //     child: Container(
        //       height: 100,
        //       width: 120,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(10),
        //         boxShadow: [BoxShadow(
        //           color: Colors.grey,
        //           offset: Offset(5, 5),
        //           blurRadius: 5,
        //         )],
        //         color: Colors.white,
        //       ),
        //     ),
        //    );
        //   }),
        // ),
      ],
    ));
  }
}
