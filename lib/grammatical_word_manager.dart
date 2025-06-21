import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'package:google_fonts/google_fonts.dart';

class GrammaticalWordsManager extends StatefulWidget {
  const GrammaticalWordsManager({super.key});

  @override
  State<GrammaticalWordsManager> createState() => _GrammaticalWordsManagerState();
}

class _GrammaticalWordsManagerState extends State<GrammaticalWordsManager> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HighlightProvider>(context);
    final words = provider.grammaticalWords.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Grammatical Words:",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Enter grammatical word",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final word = _controller.text.trim();
                if (word.isNotEmpty) {
                  provider.addGrammaticalWord(word);
                  _controller.clear();
                }
              },
              child: Text("Add"),
            )
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: words
              .map((word) => Chip(
                    label: Text(word),
                    backgroundColor: Colors.grey[200],
                  ))
              .toList(),
        )
      ],
    );
  }
}
