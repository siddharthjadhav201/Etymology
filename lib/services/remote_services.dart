
import "dart:developer";
import "package:etymology/popUps.dart";
import "package:etymology/providers.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
// import "package:http/http.dart" as http;
import "package:provider/provider.dart";
import "package:supabase_flutter/supabase_flutter.dart";


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

Future<void> annotate(BuildContext context) async {
  //setting request limit
  int requestCount=300;
  int requestCountHour=100;
  var supabase = Supabase.instance.client;
  List words = context.read<HighlightProvider>().highlightedWords;
  String username = context.read<LoginProvider>().username;
  // Map count = await getRequestCount(username);


    if(false){  //count["requestCount"]>requestCount
    showCenterPopup(context,"⚠️ You have reached your request limit for the hour.");
    } else if(false){ //count["requestCountHour"]>requestCountHour
    showCenterPopup(context,"⚠️ You have reached your request limit for the hour. Please try again later.");
  }else{
    // await supabase.from("request").insert({
    //   "username": username,
    //   "words": words,
    //   "wordcount": words.length,
    //   "requestnumber":count["requestCount"]+1,
    // });

    log("searching for words");
   Map data=await getWordData(words);
   context.read<HighlightProvider>().setHighlightWordsData(data);
  }
}

Future<Map> getWordData(List words)async{
  List response= await getDataFromDatabase(words);
  Map<dynamic,dynamic> wordData = response[0];
  List wordNotInDatabase = response[1];

  /// get data for remaining words from AI

  // Add entries for words not in database
  for(String word in wordNotInDatabase){
    wordData[word.toLowerCase()] = {
      "medical_term": word,
      "meaning": "Information currently unavailable"
    };
  }
  
  // Check for words with null meanings and update them
  for(String word in words){
    String wordKey = word.toLowerCase();
    if(wordData.containsKey(wordKey)){
      dynamic wordInfo = wordData[wordKey];
      if(wordInfo is Map && (wordInfo["meaning"] == null || wordInfo["meaning"].toString().isEmpty)){
        wordData[wordKey] = {
          "medical_term": wordInfo["medical_term"] ?? word,
          "meaning": "Information currently unavailable"
        };
      }
    }
  }

  return wordData;

}


Future<List> getDataFromDatabase(List words)async{
  var supabase = Supabase.instance.client;
  final filter = words.map((word) => 'medical_term.ilike.$word').join(',');
  try{
    final dataFromDatabase = await supabase
        .from('tbl_medical_terms')
        // .select("word,description,origin,prefix,suffix,definition")
        .select('medical_term,meaning').or(filter);
        //  print(dataFromDatabase);
  Map wordData={};
  for(var item in dataFromDatabase){
    wordData.addAll({item["medical_term"].toLowerCase():item});
  }
  List wordNotInDatabase = words.where((word) =>!wordData.keys.contains(word) ).toList();
  log("words not in database $wordNotInDatabase");
  print(wordData);
  return [wordData,wordNotInDatabase];
  }catch(e){
    log("error getDataFromDatabase $e");
    return [{},[]];
  }

  
 
  
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


Future<String?> uploadPdfToSupabase(Uint8List bytes) async {
  final supabase = Supabase.instance.client;

  // Your Supabase storage bucket name (create one in Supabase dashboard)
  const bucketName = 'pdfData';

  // Unique filename for the PDF
  final filePath = 'pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf';

  try {
    // Upload bytes directly (Flutter web compatible)
    await supabase.storage
        .from(bucketName)
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(contentType: 'application/pdf'));

    // Get the public URL after upload
    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);

    print('Uploaded successfully: $publicUrl');
    return publicUrl;
  } catch (e) {
    print(' Upload failed: $e');
    return null;
  }
}

/// Parses a CSV line handling quoted fields with commas
List<String> _parseCsvLine(String line) {
  List<String> fields = [];
  StringBuffer currentField = StringBuffer();
  bool inQuotes = false;
  
  for (int i = 0; i < line.length; i++) {
    String char = line[i];
    
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        // Escaped quote
        currentField.write('"');
        i++; // Skip next quote
      } else {
        // Toggle quote state
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      // Field separator
      fields.add(currentField.toString().trim());
      currentField.clear();
    } else {
      currentField.write(char);
    }
  }
  
  // Add last field
  fields.add(currentField.toString().trim());
  return fields;
}

/// Imports medical terms from CSV string into tbl_medical_terms
/// Updates existing terms' meanings, inserts new terms
Future<Map<String, int>> importMedicalTermsFromCsv(
  String csvContent, {
  void Function({
    required int totalLines,
    required int processedLines,
    required int inserted,
    required int updated,
    required int errors,
  })? onProgress,
}) async {
  final supabase = Supabase.instance.client;
  int inserted = 0;
  int updated = 0;
  int errors = 0;
  
  try {
    // Split CSV content into lines
    final List<String> lines = csvContent.split('\n');
    
    if (lines.isEmpty) {
      log('CSV file is empty');
      return {'inserted': 0, 'updated': 0, 'errors': 0};
    }
    
    // Skip header row
    final List<String> dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    final int totalLines = dataLines.length;
    
    log('Processing $totalLines rows from CSV');
    
    // Process in batches for better performance
    const int batchSize = 100;
    for (int i = 0; i < dataLines.length; i += batchSize) {
      final List<String> batch = dataLines.skip(i).take(batchSize).toList();
      final List<Map<String, String>> records = [];
      final List<String> batchTerms = [];
      
      for (String line in batch) {
        try {
          final List<String> fields = _parseCsvLine(line);
          if (fields.length >= 2) {
            final String medicalTerm = fields[0].trim();
            final String meaning = fields[1].trim();
            
            if (medicalTerm.isNotEmpty && meaning.isNotEmpty) {
              records.add({
                'medical_term': medicalTerm,
                'meaning': meaning,
              });
              batchTerms.add(medicalTerm);
            }
          }
        } catch (e) {
          log('Error parsing line: $line - $e');
          errors++;
        }
      }
      
      if (records.isEmpty) {
        if (onProgress != null) {
          onProgress(
            totalLines: totalLines,
            processedLines: (i + batch.length).clamp(0, totalLines),
            inserted: inserted,
            updated: updated,
            errors: errors,
          );
        }
        continue;
      }
      
      // Step 1: Query existing terms in this batch
      final Set<String> existingTerms = {};
      try {
        final List<dynamic> existingRows = await supabase
            .from('tbl_medical_terms')
            .select('medical_term')
            .inFilter('medical_term', batchTerms);
        
        for (var row in existingRows) {
          final String term = row['medical_term'] ?? '';
          if (term.isNotEmpty) {
            existingTerms.add(term.trim().toLowerCase());
          }
        }
      } catch (e) {
        log('Error querying existing terms for batch: $e');
      }
      
      // Pre-calculate how many would be inserted vs updated in this batch
      int batchInserted = 0;
      int batchUpdated = 0;
      for (final record in records) {
        final termLower = record['medical_term']!.trim().toLowerCase();
        if (existingTerms.contains(termLower)) {
          batchUpdated++;
        } else {
          batchInserted++;
        }
      }
      
      // Step 2: Try batch upsert
      try {
        await supabase
            .from('tbl_medical_terms')
            .upsert(records, onConflict: 'medical_term');
        
        inserted += batchInserted;
        updated += batchUpdated;
      } catch (e) {
        log('Batch upsert failed, falling back to individual processing: $e');
        // Fallback: process individually
        for (final record in records) {
          final String medicalTerm = record['medical_term']!;
          final String meaning = record['meaning']!;
          
          try {
            final bool isExisting = existingTerms.contains(medicalTerm.trim().toLowerCase());
            
            if (isExisting) {
              await supabase
                  .from('tbl_medical_terms')
                  .update({'meaning': meaning})
                  .eq('medical_term', medicalTerm);
              updated++;
            } else {
              await supabase
                  .from('tbl_medical_terms')
                  .insert({
                    'medical_term': medicalTerm,
                    'meaning': meaning,
                  });
              inserted++;
            }
          } catch (individualError) {
            log('Error processing individual term $medicalTerm: $individualError');
            errors++;
          }
        }
      }
      
      // Call progress callback
      if (onProgress != null) {
        onProgress(
          totalLines: totalLines,
          processedLines: (i + batch.length).clamp(0, totalLines),
          inserted: inserted,
          updated: updated,
          errors: errors,
        );
      }
    }
    
    log('Import complete: $inserted inserted, $updated updated, $errors errors');
    return {
      'inserted': inserted,
      'updated': updated,
      'errors': errors,
    };
  } catch (e, stackTrace) {
    log('Error importing CSV: $e\n$stackTrace');
    return {
      'inserted': inserted,
      'updated': updated,
      'errors': errors + 1,
    };
  }
}

/// Verifies how many terms from CSV exist in database
Future<Map<String, dynamic>> verifyCsvImportStatus() async {
  final supabase = Supabase.instance.client;
  
  try {
    // Read CSV to get all terms
    final String csvContent = await rootBundle.loadString('assets/WordList1.csv');
    final List<String> lines = csvContent.split('\n');
    final List<String> dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    
    final Set<String> csvTerms = {};
    for (String line in dataLines) {
      try {
        final List<String> fields = _parseCsvLine(line);
        if (fields.isNotEmpty) {
          csvTerms.add(fields[0].trim().toLowerCase());
        }
      } catch (e) {
        // Skip invalid lines
      }
    }
    
    // Get total count in database
    final totalInDbResponse = await supabase
        .from('tbl_medical_terms')
        .select('id')
        .count(CountOption.exact);
    
    // Check how many CSV terms exist in DB
    int foundCount = 0;
    int notFoundCount = 0;
    final List<String> notFoundTerms = [];
    
    // Check in batches
    const int batchSize = 100;
    final List<String> csvTermsList = csvTerms.toList();
    
    for (int i = 0; i < csvTermsList.length; i += batchSize) {
      final List<String> batch = csvTermsList.skip(i).take(batchSize).toList();
      final filter = batch.map((term) => 'medical_term.ilike.$term').join(',');
      
      try {
        final existing = await supabase
            .from('tbl_medical_terms')
            .select('medical_term')
            .or(filter);
        
        final Set<String> found = existing
            .map((e) => (e['medical_term'] as String).toLowerCase())
            .toSet();
        
        for (String term in batch) {
          if (found.contains(term)) {
            foundCount++;
          } else {
            notFoundCount++;
            if (notFoundTerms.length < 10) {
              notFoundTerms.add(term);
            }
          }
        }
      } catch (e) {
        log('Error checking batch: $e');
      }
    }
    
    return {
      'csvTotal': csvTerms.length,
      'dbTotal': totalInDbResponse.count,
      'foundInDb': foundCount,
      'notFoundInDb': notFoundCount,
      'sampleNotFound': notFoundTerms,
    };
  } catch (e, stackTrace) {
    log('Error verifying import: $e\n$stackTrace');
    return {
      'error': e.toString(),
    };
  }
}