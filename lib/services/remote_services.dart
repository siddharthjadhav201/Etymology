



import "dart:convert";
import "dart:developer";

import "package:etymology/providers.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart" as http;
import "package:provider/provider.dart";

// void getWordInfo()async{
//   var client = http.Client();
//   var url= Uri.parse("https://jsonplaceholder.typicode.com/posts");
//   var respose =await client.get(url);
//   if (respose.statusCode==200){
//     String json=respose.body;
//     log(json);
//   }
// }

void getWordInfo(BuildContext context)async{
  HighlightProvider highlightProvider = context.read<HighlightProvider>();
  var jsonData=[];
  try{
    String jsonString = await rootBundle.loadString('MultipleEtymoSearch.json');
    jsonData = jsonDecode(jsonString);

  }catch (e){
    log("error while retrieving data from json file");
    print(e);
  }

  List wordsInDatabase=[];
  for(Map item in jsonData){
    try{
    wordsInDatabase.add(item["etymoword"]);
    }catch(e){
      log("error in database");
    }
  }
  print(wordsInDatabase);

  List highlightWordsData=[];
for(String word in highlightProvider.highlightedWords){
  if(wordsInDatabase.contains(word)){
    highlightWordsData.add({"name":word,"description":jsonData[wordsInDatabase.indexOf(word)]["description"]});
}else{
  highlightWordsData.add({"name":word,"description":"Data currently unavailable"});
}
    highlightProvider.setHighlightWordsData(highlightWordsData);
}

}


