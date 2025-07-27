import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<bool> addNonScientificTerm(String term) async {
    final response = await http.post(
      Uri.parse('$baseUrl/non_scientific_term/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'term': term}),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false; // Already exists
    } else {
      throw Exception('Failed to add non-scientific term');
    }
  }

  static Future<bool> isNonScientific(String word) async {
    final response = await http.get(
      Uri.parse('$baseUrl/non_scientific_term/check?term=$word'),
    );

    return response.statusCode == 200;
  }

  static Future<List<dynamic>> fetchWords() async {
    final response = await http.get(Uri.parse('$baseUrl/words'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load medical words');
    }
  }

  static Future<Map<String, dynamic>> searchWords(List<String> words) async {
    List<Map<String, dynamic>> foundData = [];
    List<String> notFoundWords = [];

    for (String word in words) {
      final response = await http.get(
        Uri.parse('$baseUrl/words/search?word=$word'),
      );

      if (response.statusCode == 200) {
        foundData.add(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        notFoundWords.add(word);
      } else {
        throw Exception('Server error while fetching $word');
      }
    }

    return {
      'found': foundData,
      'notFound': notFoundWords,
    };
  }
}
