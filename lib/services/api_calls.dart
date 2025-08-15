
import 'dart:developer';

import 'package:etymology/providers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future fetchMedicalTerms(HighlightProvider highlightProvider) async{  
  List highlightedWords=highlightProvider.highlightedWords;
  final uri=Uri.https('2ad9d3bc0a8a.ngrok-free.app', '/get_word_data/',{"highlightedWords":highlightedWords});
  // final uri=Uri.https('99f4d3282f39.ngrok-free.app', '/check_connection/');
  var response= await http.post(uri, headers: {
      "ngrok-skip-browser-warning": "true", // This skips the warning
    },);
  if(response.body.isEmpty){return;}
  Map responseData=jsonDecode(response.body);
  List datalist=responseData['results'];
   Map data = Map.fromEntries(datalist.map((item){
  return MapEntry(item[0].toLowerCase(), {'word':item[0],'description':item[1]});},));
  highlightProvider.setHighlightWordsData(data);
}



// static Future<Map<String, dynamic>> searchWords(List<String> words) async {
//     List<Map<String, dynamic>> foundData = [];
//     List<String> notFoundWords = [];

//     for (String word in words) {
//       final response = await http.get(
//         Uri.parse('$baseUrl/words/search?word=$word'),
//       );

//       if (response.statusCode == 200) {
//         foundData.add(jsonDecode(response.body));
//       } else if (response.statusCode == 404) {
//         notFoundWords.add(word);
//       } else {
//         throw Exception('Server error while fetching $word');
//       }
//     }

//     return {
//       'found': foundData,
//       'notFound': notFoundWords,
//     };
//   }