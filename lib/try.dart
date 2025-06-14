
import "package:etymology/navbar.dart";
import "package:flutter/material.dart";
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
 
 void _highlightSelection() {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final selectedWord = text.substring(selection.start, selection.end).trim();
    if (selectedWord.isEmpty) return;

    final success = context.read<HighlightProvider>().toggleHighlight(selectedWord);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can highlight up to 10 words only.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final highlightProvider = Provider.of<HighlightProvider>(context);
    return Scaffold(
        body: Column(
      children: [
        CustomNavbar(),
        Padding(
          padding: EdgeInsets.only(top: 55, right: 140, left: 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(25.0),
                width: 958,
                height: 83,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/i.png",
                      height: 28,
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: Colors.black),
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
              const SizedBox(
                height: 27,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      width: 124,
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
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {_highlightSelection();},
                    child: Container(
                        height: 48,
                        width: 180,
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
                              height: 44,
                              width: 44,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Highlight',
                                style: GoogleFonts.poppins(
                                    letterSpacing: 0.08,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                          ],
                        )),
                  ),
                  
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      width: 144,
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
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    ),
                  ),
                  const SizedBox(
                    width: 28,
                  )
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Container(
                height: 380,
                width: 1160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                  width: 1,
                  color: Color.fromARGB(255, 166, 166, 166),
                )),
                alignment: Alignment.topLeft,
                child: ExtendedTextField(
            controller: controller,
            expands: true,
            maxLines: null,
            specialTextSpanBuilder: HighlightSpanBuilder(highlightProvider),
            decoration: InputDecoration.collapsed(hintText: "Type and select words to highlight"),
          ),
              ),
              
              const SizedBox(height: 28,),
              GestureDetector(
                    onTap: () {

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            height: 48,
                            width: 180,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255,54,59,186),
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
                                  width: 10,
                                ),
                                Text('Annotate',
                                    style: GoogleFonts.poppins(
                                        letterSpacing: 0.08,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ],
                            )),
                      ],
                    ),
                  ),
                const SizedBox(height: 20,),
                 Wrap(
          children: highlightProvider.highlightedWords
              .map((word) => Chip(label: Text(word)))
              .toList(),
        ),  
            ],
          ),
        ),
      ],
    ));
  }
}
