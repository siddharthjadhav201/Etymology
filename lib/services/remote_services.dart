
import "dart:convert";
import "dart:developer";
import "package:etymology/providers.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
// import "package:http/http.dart" as http;
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";

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

Future<int> registerUser(String name, String email, String username, String selectedRole,
    String password) async {
  var supabase = Supabase.instance.client;
  try {
    final data = await supabase
        .from('login')
        .select("id")
        .or("email.eq.$email ,username.eq.$username");
    if (data.isNotEmpty) {
      log("email or username already taken");
      return 0;
    } else {
      await Supabase.instance.client.from("login").insert({
        "name": name,
        "role": selectedRole,
        "username": username,
        "password": password,
        "email": email,
      });
      return 1;
    }
  } catch (e) {
    log("$e");
    return -1;
  }
}

Future<int> loginUser(String username, String password) async {
  var supabase = Supabase.instance.client;

  try {
    final data = await supabase
        .from('login')
        .select("id , password")
        .eq("username", username);
    if (data.isEmpty) {
      log("User Not Found");
      return 0;
    } else if (data[0]["password"] != password) {
      log("Incorrect Password");
      return 1;
    } else {
      log("login");
      return 2;
    }
  } catch (e) {
    log("$e");
    return 3;
  }
}

Future<Map> getRequestCount(String username) async {
  Map data={"requestCount":0,"requestCountHour":0};
  var supabase = Supabase.instance.client;
  try {
    // user's all request
    final requestData =
        await supabase.from('request').select("id").eq("username", username);
        data["requestCount"]= requestData.length;
    // return data.length;

    final oneHourAgo =
        DateTime.now().toUtc().subtract(Duration(hours: 1)).toIso8601String();

        log(oneHourAgo);

    //Request in one hour
    final requestDataLastHour = await supabase
        .from('request')
        .select("id")
        .gte('created_at', oneHourAgo);
         data["requestCountHour"]= requestDataLastHour.length;

  } catch (e) {
    log("$e");
  }
  return data;
}

void annotate(BuildContext context) async {
  //setting request limit
  int requestCount=30;
  int requestCountHour=5;
  var supabase = Supabase.instance.client;
  List words = context.read<HighlightProvider>().highlightedWords;
  String username = context.read<LoginProvider>().username;
  Map count = await getRequestCount(username);

  if(count["requestCount"]>requestCount){
    showCenterPopup(context,"⚠️ You have reached your request limit for the hour.");
  } else if(count["requestCountHour"]>requestCountHour){
    showCenterPopup(context,"⚠️ You have reached your request limit for the hour. Please try again later.");
  }else{
    await supabase.from("request").insert({
      "username": username,
      "words": words,
      "wordcount": words.length,
      "requestnumber":count["requestCount"]+1,
    });

    log("searching for words");
   Map data=await getWordData(words);
   context.read<HighlightProvider>().setHighlightWordsData(data);
  }
}

Future<Map> getWordData(List words)async{
  List response= await getDataFromDatabase(words);

  /// get data for remaining words from AI

  return response[0];

}


Future<List> getDataFromDatabase(List words)async{
  var supabase = Supabase.instance.client;
  final filter = words.map((word) => 'word.eq.$word').join(',');
  final dataFromDatabase = await supabase
        .from('medical_terms')
        .select("word,description,origin,prefix,suffix,definition")
        .or(filter);
  print(dataFromDatabase);
  Map wordData={};
  for(var item in dataFromDatabase){
    wordData.addAll({item["word"]:item});
  }
  List wordNotInDatabase = words.where((word) =>!wordData.keys.contains(word) ).toList();
  log("words not in database $wordNotInDatabase");
  return [wordData,wordNotInDatabase];
}




// void getWordInfoFromJson(BuildContext context) async {
//   HighlightProvider highlightProvider = context.read<HighlightProvider>();
//   var jsonData = [];
//   try {
//     String jsonString = await rootBundle.loadString('MultipleEtymoSearch.json');
//     jsonData = jsonDecode(jsonString);
//   } catch (e) {
//     log("error while retrieving data from json file");
//     print(e);
//   }
//   List wordsInDatabase = [];
//   for (Map item in jsonData) {
//     try {
//       wordsInDatabase.add(item["etymoword"]);
//     } catch (e) {
//       log("error in database");
//     }
//   }
//   print(wordsInDatabase);

//   List highlightWordsData = [];
//   for (String word in highlightProvider.highlightedWords) {
//     if (wordsInDatabase.contains(word)) {
//       highlightWordsData.add({
//         "name": word,
//         "description": jsonData[wordsInDatabase.indexOf(word)]["description"]
//       });
//     } else {
//       highlightWordsData
//           .add({"name": word, "description": "Data currently unavailable"});
//     }
//     highlightProvider.setHighlightWordsData(highlightWordsData);
//   }
// }

// addUser() async {
//   try {
//     await Supabase.instance.client.from("login").insert({
//       "id": 5,
//       "name": "sanket",
//       "role": "student",
//       "username": "sanket8555",
//       "password": "1234"
//     });
//   } on PostgrestException catch (e) {
//     log(e.message);
//   }
// }

// void getWordInfoFromAPI()async{
//   var client = http.Client();
//   var url= Uri.parse("https://jsonplaceholder.typicode.com/posts");
//   var respose =await client.get(url);
//   if (respose.statusCode==200){
//     String json=respose.body;
//     log(json);
//   }
// }


