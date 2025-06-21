import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grammatical_word_manager.dart';
import 'providers.dart';
class GrammarWordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final highlightProvider = Provider.of<HighlightProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Highlighted Words")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GrammaticalWordsManager(),
      ),
    );
  }
}
