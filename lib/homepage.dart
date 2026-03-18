import "dart:developer";

// import "package:etymology/grammaticalwordpage.dart";
import "package:etymology/pdfExport.dart";
import "package:etymology/highlight_block_formatter.dart";
import "package:etymology/navbar.dart";
import "package:etymology/pdfStructure.dart";
import "package:etymology/popUps.dart";
// import "package:etymology/services/api_calls.dart";
import "package:etymology/notes_search_bar.dart";
import "package:etymology/notes_search_provider.dart";
import "package:etymology/services/remote_services.dart";
import "package:etymology/string_functions.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
// import "package:http/http.dart";
import "package:provider/provider.dart";
import "package:universal_html/html.dart" as html;
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
  final GlobalKey _noteFieldKey = GlobalKey();

  /// Floating search (Ctrl+F): shared so inline and floating bar stay in sync.
  late final TextEditingController _searchTextController =
      TextEditingController();
  late final FocusNode _searchFocusNode = FocusNode();
  bool _showFloatingSearch = false;
  void Function(html.Event)? _webKeyHandler;
  static const _floatingSearchWidth = 320.0;

  @override
  void initState() {
    super.initState();

    var highlightProvider = context.read<HighlightProvider>();
    highlightProvider.noteController = noteController;
    highlightProvider.homeScreenContext = context;
    noteController.addListener(() {
      highlightProvider.removeDescriptionPopUp();

      // Reactive search: update matches on every text change (note + annotations)
      context.read<NotesSearchProvider>().updateMatches(
            noteController.text,
            _annotationTextsBuilder(),
          );

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

    if (kIsWeb) {
      _webKeyHandler = (html.Event e) {
        if (e is! html.KeyboardEvent) return;
        if (e.ctrlKey && (e.key == 'f' || e.key == 'F')) {
          e.preventDefault();
          if (mounted) {
            setState(() => _showFloatingSearch = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          }
          return;
        }
        if (e.key == 'Escape') {
          if (mounted) {
            _searchTextController.clear();
            context.read<NotesSearchProvider>().clearSearch();
            setState(() => _showFloatingSearch = false);
          }
        }
      };
      html.document.addEventListener('keydown', _webKeyHandler!);
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _webKeyHandler != null) {
      html.document.removeEventListener('keydown', _webKeyHandler!);
    }
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
        showCenterPopup(context, "You can highlight up to 25 words only !.");
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

  List<String> _annotationTextsBuilder() {
    final highlightProvider = context.read<HighlightProvider>();
    final Map highlightWordsData = highlightProvider.highlightWordsData;
    final List keys = highlightWordsData.keys.toList();
    return keys.map((k) {
      final data = highlightWordsData[k];
      final term = (data["medical_term"] ?? "").toString();
      final meaning = (data["meaning"] ?? "").toString();
      return '$term $meaning';
    }).toList();
  }

  @override
  void deactivate() {
    final highlightProvider = Provider.of<HighlightProvider>(context);
    noteController.clear();
    highlightProvider.clear();
    highlightProvider.setAnnotatedStatus(false);
    log("dispose called");
    super.deactivate();
  }

  void _onSearchNavigate(SearchNavigationTarget target) {
    if (target.isNote && target.noteRange != null) {
      final r = target.noteRange!;
      noteController.selection =
          TextSelection(baseOffset: r.start, extentOffset: r.end);
      _scrollToNoteMatch(r);
      return;
    }
    // Annotation navigation restored
    if (!target.isNote && target.annotationIndex != null) {
      final ctx = _annotationKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    }
  }

  void _scrollToNoteMatch(SearchRange range) {
    try {
      final text = noteController.text;
      if (text.isEmpty) return;
      final ctx = _noteFieldKey.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final width = box.size.width;
      final viewportHeight = box.size.height;

      final painter = TextPainter(
        text: TextSpan(
          text: text.substring(0, range.start),
          style: const TextStyle(fontSize: 15),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      final offsetY = painter.height;

      final maxScroll = noteScrollController.position.maxScrollExtent;
      final targetOffset =
          (offsetY - viewportHeight * 0.3).clamp(0.0, maxScroll);
      noteScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // Fail silently; do not break editor if scroll calculations fail.
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final highlightProvider = Provider.of<HighlightProvider>(context);

    Widget buildButtonWithIcon(
        String label, double w, String iconPath, VoidCallback onTap) {
      return MouseRegion(
        cursor: (label == "Highlight" || label == "Unhighlight")
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
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
        ),
      );
    }

    Widget buildButton(String label, double w, VoidCallback onTap) {
      return MouseRegion(
        cursor: label == "Clear All"
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: width * 0.0041, horizontal: width * 0.0124),
            height: width * 0.03,
            width: w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: Color.fromARGB(255, 166, 166, 166)),
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
                                  fontSize: width * 0.012, color: Colors.black),
                              children: [
                                TextSpan(
                                    text:
                                        'Type or Copy Paste your study notes and click '),
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
                      buildButton("Paste", width * 0.0761, () async {
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
                    key: _noteFieldKey,
                    height: width * 0.263,
                    padding: EdgeInsets.all(width * 0.007),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: Color.fromARGB(255, 166, 166, 166),
                        )),
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: [
                        // Hidden text layer for browser search (Ctrl+F) functionality
                        // This makes the text searchable by browsers while keeping the visual highlighting
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity:
                                  0.01, // Very low opacity but not 0 to ensure it's in DOM
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: noteController,
                                builder: (context, value, child) {
                                  return SelectableText(
                                    value.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height:
                                          1.5, // Match line height if needed
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Visible text field with highlighting
                        TextSelectionTheme(
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
                                highlightProvider,
                                context,
                                noteController,
                                context.read<NotesSearchProvider>()),
                            decoration: InputDecoration.collapsed(
                                hintText:
                                    "Type or copy paste the text and select words to highlight"),
                          ),
                        ),
                      ],
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
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                if (highlightProvider
                                    .highlightedWords.isNotEmpty) {
                                  highlightProvider.removeDescriptionPopUp();
                                  if (noteController.text.isNotEmpty) {
                                    highlightProvider.setAnnotatedStatus(true);
                                    await annotate(context);
                                    // await fetchMedicalTerms(highlightProvider);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
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
                                        height: width * 0.017,
                                        width: width * 0.017),
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
                          child: Consumer<NotesSearchProvider>(
                            builder: (context, searchProvider, _) {
                              final activeAnnoIndex =
                                  searchProvider.currentTarget?.isNote == false
                                      ? searchProvider
                                          .currentTarget!.annotationIndex
                                      : null;
                              final query =
                                  searchProvider.query.trim().toLowerCase();

                              Text _buildHighlightedText(
                                  String text, bool isActiveRow) {
                                if (query.isEmpty) {
                                  return Text(text);
                                }
                                final lower = text.toLowerCase();
                                final spans = <TextSpan>[];
                                int start = 0;
                                while (true) {
                                  final i = lower.indexOf(query, start);
                                  if (i == -1) {
                                    if (start < text.length) {
                                      spans.add(TextSpan(
                                          text: text.substring(start)));
                                    }
                                    break;
                                  }
                                  if (i > start) {
                                    spans.add(TextSpan(
                                        text: text.substring(start, i)));
                                  }
                                  spans.add(TextSpan(
                                    text: text.substring(i, i + query.length),
                                    style: TextStyle(
                                      backgroundColor: isActiveRow
                                          ? Colors.cyan.withAlpha(190)
                                          : Colors.cyan.withAlpha(100),
                                    ),
                                  ));
                                  start = i + query.length;
                                }
                                return Text.rich(TextSpan(children: spans));
                              }

                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: highlightProvider
                                      .highlightWordsData.keys.length,
                                  itemBuilder: (context, index) {
                                    Map highlightWordsData =
                                        highlightProvider.highlightWordsData;
                                    List keys =
                                        highlightWordsData.keys.toList();

                                    final bool isActiveRow =
                                        activeAnnoIndex == index;

                                    final data = highlightProvider
                                        .highlightWordsData[keys[index]];
                                    final term =
                                        (data["medical_term"] ?? "").toString();
                                    final meaning = (data["meaning"] ??
                                            "Information currently unavailable")
                                        .toString();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHighlightedText(
                                          term,
                                          isActiveRow,
                                        ),
                                        _buildHighlightedText(
                                          meaning,
                                          isActiveRow,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                        ),

                  SizedBox(
                    height: width * 0.021,
                  ),

                  (highlightProvider.isAnnotated &&
                          !highlightProvider.highlightWordsData.isEmpty)
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
        highlightProvider.descriptionPopUp ?? Text(""),
        if (kIsWeb && _showFloatingSearch)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: _floatingSearchWidth,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Search in note',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              tooltip: 'Close (Esc)',
                              onPressed: () {
                                _searchTextController.clear();
                                context
                                    .read<NotesSearchProvider>()
                                    .clearSearch();
                                setState(() => _showFloatingSearch = false);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                        NotesSearchBar(
                          searchController: _searchTextController,
                          searchFocusNode: _searchFocusNode,
                          requestFocusOnMount: true,
                          noteController: noteController,
                          annotationTextsBuilder: _annotationTextsBuilder,
                          onNavigate: _onSearchNavigate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ));
  }
}
