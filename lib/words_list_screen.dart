import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WordsListScreen extends StatelessWidget {
  const WordsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Words')),
      body: FutureBuilder(
        future: ApiService.fetchWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List words = snapshot.data as List;
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return Column(
                  children: [
                    Container(
                      height: 200,
                      width: 900,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                      title: Text(word['Medical_Term'] ?? ''),
                      subtitle: Text(
                        'Description: ${word['Term_Des'] ?? '-'}\n'
                        'Origin: ${word['Term_origin'] ?? '-'}\n'
                        'Prefix: ${word['prefix'] ?? '-'}\n'
                        'Suffix: ${word['suffix'] ?? '-'}\n'
                        'Definition: ${word['Term_def'] ?? '-'}\n',
                      ),
                    )
                    ),
                  SizedBox(height: 20,)
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
