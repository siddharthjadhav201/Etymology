



import "dart:developer";

import "package:http/http.dart" as http;

void getWordInfo()async{
  var client = http.Client();
  var url= Uri.parse("https://jsonplaceholder.typicode.com/posts");
  var respose =await client.get(url);
  if (respose.statusCode==200){
    String json=respose.body;
    log(json);
  }
}