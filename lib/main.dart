
import 'package:etymology/human_in_loop.dart';
import 'package:etymology/login_page.dart';
import 'package:etymology/pdfHistoryPage.dart';
import 'package:etymology/providers.dart';
import 'package:etymology/try.dart';
import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart';
import 'main_page.dart';
void main() async{
 WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://ynysnloiyrfkqcjalsrl.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlueXNubG9peXJma3FjamFsc3JsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NjU0MDEsImV4cCI6MjA2NjM0MTQwMX0.sy5nOpnQrwzMVUSPci8tLsoALPZS7zn2--Rx1e6pa7s",
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => HighlightProvider()),
    ChangeNotifierProvider(create: (_) => LoginProvider()),
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
      // home:PdfHistoryPage(),
      home: MyWidget(),
      
    );
  }
  
  
}
