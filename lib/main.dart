import 'package:etymology/providers.dart';
import 'package:flutter/material.dart';
import "package:provider/provider.dart";

import 'try.dart';
void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => HighlightProvider()),
  ],
    child: MainApp(),

  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesEditor(),
      //Secondpage(),
      //NotesEditor(),
    );
  }
}
