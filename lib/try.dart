// import statements
import "dart:developer";
import 'package:etymology/highlight_block_formatter.dart';
import "package:etymology/navbar.dart";
import 'package:etymology/popUps.dart';
import 'package:etymology/string_functions.dart';
import "package:flutter/material.dart";
import 'package:printing/printing.dart';
import "package:provider/provider.dart";
import 'package:google_fonts/google_fonts.dart';
import 'highlight_spanbuilder.dart';
import 'services/api_service.dart';
import 'providers.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'pdf_generator.dart';

class NotesEditor extends StatefulWidget {
  @override
  _NotesEditorState createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {
  final TextEditingController noteController = TextEditingController();
  final UndoHistoryController undoController = UndoHistoryController();
  TextSelection? previousSelection;
  bool _limitPopupShown = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _annotationKey = GlobalKey();

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

  bool isAlphanumeric(String char) => RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
  bool isSymbol(String char) => !RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);

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
  // void updateLocations() {
  //   HighlightProvider provider = context.read<HighlightProvider>();
  //   int diff = noteController.text.length - provider.prevTextLength;
  //   provider.highlightedRanges =
  //       provider.highlightedRanges.map((loc) {
  //     if (loc[0] > previousSelection!.start) {
  //       return [loc[0] + diff, loc[1] + diff];
  //     }
  //     return loc;
  //   }).toList();
  //   provider.setPrevTextLength(noteController.text.length);
  // }

  @override
  Widget build(BuildContext context) {
    final highlightProvider = Provider.of<HighlightProvider>(context);
    final width = MediaQuery.of(context).size.width;

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
      body: ListView(
        controller: _scrollController,
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
                // Info Box
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
                      Image.asset("assets/i.png", height: width * 0.019),
                      SizedBox(width: width * 0.007),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.0138,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Paste your study notes and click '),
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
                SizedBox(height: width * 0.013),

                // Buttons
                Row(
                  children: [
                    buildButton("Paste", width * 0.0761, () {}),
                    SizedBox(width: width * 0.014),
                    buildButtonWithIcon("Highlight", width * 0.125,
                        "assets/brush-square.png", _highlightSelection),
                    Spacer(),
                    buildButton("Clear All", width * 0.1, () {
                      highlightProvider.clear();
                    }),
                    // SizedBox(width: width * 0.0194),
                  ],
                ),
                SizedBox(height: width * 0.018),

                Container(
                  // height: highlightProvider.isAnnotated
                  //     ? width * 0.263 / 2
                  //     : width * 0.263,
                  height: width * 0.263,
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
                      maxLength: 5000,
                      specialTextSpanBuilder:
                          HighlightSpanBuilder(highlightProvider, context),
                      decoration: InputDecoration.collapsed(
                          hintText: "Type and select words to highlight"),
                    ),
                  ),
                ),
                SizedBox(height: width * 0.018),

                // Annotate Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      final words =
                          List<String>.from(highlightProvider.highlightedWords);
                      try {
                        final result = await ApiService.searchWords(words);
                        highlightProvider
                            .setHighlightWordsData(result['found']);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final context = _annotationKey.currentContext;
                          if (context != null) {
                            Scrollable.ensureVisible(
                              context,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        });

                        if (result['notFound'].isNotEmpty) {
                          showCenterPopup(context,
                              "⚠️ Not found in DB:\n${result['notFound'].join(', ')}");
                        }
                      } catch (e) {
                        print("Error fetching words: $e");
                        showCenterPopup(
                            context, "❌ Server error while fetching data.");
                      }
                    },
                    child: Container(
                      height: width * 0.034,
                      width: width * 0.17,
                      // padding: EdgeInsets.symmetric(horizontal: width*0.0056),
                      decoration: BoxDecoration(
                        color: const Color(0xFF363BBA),
                        border: Border.all(
                            color: Color.fromARGB(255, 166, 166, 166)),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                ),

                SizedBox(height: width * 0.018),

                // Word List (Optional)
                highlightProvider.highlightWordsData.isEmpty
                    ? SizedBox()
                    : Container(
                        key: _annotationKey,
                        // width: width * 0.805,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Color.fromARGB(255, 166, 166, 166)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              highlightProvider.highlightWordsData.length,
                          itemBuilder: (context, index) {
                            final data =
                                highlightProvider.highlightWordsData[index];
                            return GestureDetector(
                              onTap: () {
                                highlightProvider.setSelectedWord(
                                    data['Medical_Term'], data['Term_Des']);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Medical Term: ${data['Medical_Term']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Description: ${data['Term_Des']}"),
                                  Text("Origin: ${data['Term_origin']}"),
                                  Text("Prefix: ${data['prefix']}"),
                                  Text("Suffix: ${data['suffix']}"),
                                  Text("Definition: ${data['Term_def']}"),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 30,
                ),

                highlightProvider.highlightWordsData.isEmpty
                    ? SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButtonWithIcon("Edit Note ", width * 0.131,
                              "assets/edit.png", () {}),
                          buildButtonWithIcon(
                              "Export", width * 0.13, "assets/export.png", () {
                            if (highlightProvider
                                .highlightWordsData.isNotEmpty) {
                              exportNotesPopUp(context,
                                  highlightProvider.highlightWordsData);
                            }
                          }),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
