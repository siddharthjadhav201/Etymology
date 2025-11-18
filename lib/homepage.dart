import "dart:developer";

// import "package:etymology/grammaticalwordpage.dart";
import "package:etymology/pdfExport.dart";
import "package:etymology/highlight_block_formatter.dart";
import "package:etymology/navbar.dart";
import "package:etymology/pdfStructure.dart";
import "package:etymology/popUps.dart";
// import "package:etymology/services/api_calls.dart";
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
  ScrollController homePageScrollController = ScrollController();
  ScrollController noteScrollController = ScrollController();
  TextEditingController noteController = TextEditingController();
  final GlobalKey _annotationKey = GlobalKey();
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
      highlightProvider.removeDescriptionPopUp();
      if (noteController.text.length >= 20000 && !_limitPopupShown) {
        _limitPopupShown = true;
        showCenterPopup(context, "You have reached the character limit.");
      }

      if (noteController.text.length < 20000) {
        _limitPopupShown = false;
      }
    });
    noteScrollController.addListener(() {
      highlightProvider.removeDescriptionPopUp();
      log("scrolled");
    });
    homePageScrollController.addListener(() {
      highlightProvider.removeDescriptionPopUp();
      log("scrolled");
    });
  }

  void _highlightSelection() {
    var highlightProvider = context.read<HighlightProvider>();
    log("${noteController.selection.start}  ,  ${noteController.selection.end}");
    final text = noteController.text;
    if (!noteController.selection.isValid ||
        noteController.selection.isCollapsed) return;
    final selection = noteController.selection;
    int start = 0;
    int end = 0;
    start = text[selection.start] == " " || isSymbol(text[selection.start])
        ? start = selection.start + 1
        : start = selection.start;
    end = text[selection.end - 1] == " " || isSymbol(text[selection.end - 1])
        ? end = selection.end - 1
        : end = selection.end;
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
                : isAlphanumeric(text[end])) {
      log("${text.substring(start, end).trim().toLowerCase()}");
      log(text[end]);
      log("2");
      return;
    } else {
      final selectedWord = text.substring(start, end).trim().toLowerCase();

      if (selectedWord.isEmpty ||
          !isValidWordCount(selectedWord) ||
          containsSymbol(selectedWord)) {
        log(selectedWord);
        log("3");
        return;
      }

      if (highlightProvider.isGrammatical(selectedWord)) {
        showCenterPopup(context,
            "⚠️ '$selectedWord' is not a scientific term and cannot be highlighted.");
        return;
      }
      final success = highlightProvider.addHighlight(
          selectedWord.toLowerCase(), start, end);
      if (success == 1) {
        showCenterPopup(context, "You can highlight up to 10 words only !.");
      } else if (success == 2) {
        showCenterPopup(context, "Selected word is already highlighted !.");
      }
    }
  }

  void _unhighlightSelection() {
    var highlightProvider = context.read<HighlightProvider>();
    log("${noteController.selection.start}  ,  ${noteController.selection.end}");
    final text = noteController.text;
    if (!noteController.selection.isValid ||
        noteController.selection.isCollapsed) return;
    final selection = noteController.selection;
    int start = 0;
    int end = 0;
    start = text[selection.start] == " " || isSymbol(text[selection.start])
        ? start = selection.start + 1
        : start = selection.start;
    end = text[selection.end - 1] == " " || isSymbol(text[selection.end - 1])
        ? end = selection.end - 1
        : end = selection.end;
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
                : isAlphanumeric(text[end])) {
      log("${text.substring(start, end).trim().toLowerCase()}");
      log(text[end]);
      log("2");
      return;
    } else {
      final selectedWord = text.substring(start, end).trim().toLowerCase();

      if (selectedWord.isEmpty ||
          !isValidWordCount(selectedWord) ||
          containsSymbol(selectedWord)) {
        log(selectedWord);
        log("3");
        return;
      }

      final success = highlightProvider.removeHighlight(
          selectedWord.toLowerCase(), start, end);
      if (success == 2) {
        showCenterPopup(context, "Selected word is not highlighted !.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final highlightProvider = Provider.of<HighlightProvider>(context);

    Widget buildButtonWithIcon(
        String label, double w, String iconPath, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: width * 0.03,
          width: w,
          // padding: EdgeInsets.symmetric(horizontal: width*0.0056),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 166, 166, 166)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath,
                  height: width * 0.024, width: width * 0.024),
              SizedBox(width: width * 0.0042),
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: width * 0.014),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildButton(String label, double w, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: width * 0.0041, horizontal: width * 0.0124),
          height: width * 0.03,
          width: w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border:
                Border.all(width: 1, color: Color.fromARGB(255, 166, 166, 166)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: width * 0.014,
            ),
          ),
        ),
      );
    }

    return Scaffold(
        body: Stack(
      children: [
        ListView(
          controller: homePageScrollController,
          children: [
            CustomNavbar(),
            Padding(
              padding: EdgeInsets.only(
                  top: width * 0.020,
                  right: width * 0.09,
                  left: width * 0.09,
                  bottom: width * 0.020),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: width * 0.01, horizontal: width * 0.025),
                    width: width * 0.665,
                    height: width * 0.043,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                                  fontSize: width * 0.012,
                                  color: Colors.black),
                              children: [
                                TextSpan(
                                    text: 'Type or Copy Paste your study notes and click '),
                                TextSpan(
                                  text: '‘Annotate’',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
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
                    height: width * 0.013,
                  ),
                  Row(
                    children: [
                      buildButton("Paste", width * 0.0761, () async{
                        // genaratePDF(noteController.text,highlightProvider.highlightedRanges,{});
                        //  await fetchMedicalTerms(highlightProvider);
                      }),
                      SizedBox(width: width * 0.014),
                      buildButtonWithIcon("Highlight", width * 0.125,
                          "assets/brush-square.png", _highlightSelection),
                      SizedBox(width: width * 0.014),
                      buildButtonWithIcon("Unhighlight", width * 0.145,
                          "assets/brush-square.png", _unhighlightSelection),
                      Spacer(),
                      buildButton("Clear All", width * 0.1, () {
                        noteController.clear();
                        highlightProvider.clear();
                      }),
                      // SizedBox(width: width * 0.0194),
                    ],
                  ),
                  SizedBox(
                    height: width * 0.018,
                  ),
                  Container(
                    height: width * 0.263,
                    padding: EdgeInsets.all(width * 0.007),
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
                        scrollController: noteScrollController,
                        autofocus: highlightProvider.editorFocusState,
                        style: TextStyle(fontSize: 15),
                        inputFormatters: [
                          HighlightBlockFormatter(
                              highlightProvider.highlightedRanges, context)
                        ],
                        controller: noteController,
                        expands: true,
                        maxLines: null,
                        maxLength: 20000,
                        specialTextSpanBuilder: HighlightSpanBuilder(
                            highlightProvider, context, noteController),
                        decoration: InputDecoration.collapsed(
                            hintText: "Type or copy paste the text and select words to highlight"),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: width * 0.018,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      highlightProvider.isAnnotated
                          ? buildButtonWithIcon(
                              "Edit Note ", width * 0.131, "assets/edit.png",
                              () {
                            highlightProvider.setAnnotatedStatus(false);
                          })
                          : SizedBox(),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector( 
                            onTap: () async {
                              if(highlightProvider.highlightedWords.isNotEmpty){
                                highlightProvider.removeDescriptionPopUp();
                              if (noteController.text.isNotEmpty) {
                                highlightProvider.setAnnotatedStatus(true);
                                await annotate(context);
                                // await fetchMedicalTerms(highlightProvider);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final ctx = _annotationKey.currentContext;
                                  if (ctx != null) {
                                    Scrollable.ensureVisible(
                                      ctx,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                });
                              }
                              }
                              
                            },
                            child: Container(
                              height: width * 0.034,
                              width: width * 0.17,
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
                                  Image.asset("assets/magicpen.png",
                                      height: width * 0.017, width: width * 0.017),
                                  SizedBox(width: width * 0.0042),
                                  Text(
                                    "Annotate",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: width * 0.014,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(height: width * 0.018),
                          // highlightProvider.isAnnotated
                          //     ? buildButtonWithIcon(
                          //         "Export",
                          //         width * 0.13,
                          //         "assets/export.png",
                          //         () {
                          //           if (noteController.text.isNotEmpty) {
                          //             exportNotesPopUp(
                          //                 context,
                          //                 highlightProvider.highlightWordsData,
                          //                 noteController.text);
                          //           }
                          //         },
                          //       )
                             // : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: width * 0.018,
                  ),

                  //annotate box
                  !highlightProvider.isAnnotated
                      ? SizedBox()
                      : Container(
                          key: _annotationKey,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 1,
                                color: Color.fromARGB(255, 166, 166, 166),
                              )),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: highlightProvider
                                  .highlightWordsData.keys.length,
                              itemBuilder: (context, index) {
                                Map highlightWordsData =
                                    highlightProvider.highlightWordsData;
                                List keys = highlightWordsData.keys.toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${highlightProvider.highlightWordsData[keys[index]]["medical_term"]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                        "${highlightProvider.highlightWordsData[keys[index]]["meaning"] ?? "Information currently unavailable"}"
                                        ),
                                    // Text(
                                    //     "origin : ${highlightProvider.highlightWordsData[keys[index]]["origin"]}"),
                                    // Text(
                                    //     "prefix : ${highlightProvider.highlightWordsData[keys[index]]["prefix"]}"),
                                    // Text(
                                    //     "suffix : ${highlightProvider.highlightWordsData[keys[index]]["suffix"]}"),

                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                );
                              }),
                        ),

                  SizedBox(
                    height: width * 0.021,
                  ),

                  (highlightProvider.isAnnotated && !highlightProvider.highlightWordsData.isEmpty)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildButtonWithIcon(
                                "Edit Note ", width * 0.131, "assets/edit.png",
                                () {
                              highlightProvider.setAnnotatedStatus(false);
                            }),
                            buildButtonWithIcon(
                              "Export",
                              width * 0.13,
                              "assets/export.png",
                              () {
                                if (noteController.text.isNotEmpty) {
                                  exportNotesPopUp(
                                      context,
                                      highlightProvider.highlightWordsData,
                                      noteController.text);
                                }
                              },
                            )
                          ],
                        )
                      : SizedBox(),

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
        highlightProvider.descriptionPopUp ?? Text("")
      ],
    ));
  }
}
