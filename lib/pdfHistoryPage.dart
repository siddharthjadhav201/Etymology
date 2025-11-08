import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'package:supabase_flutter/supabase_flutter.dart'; // For opening PDFs in new tab (Flutter web)

class PdfHistoryPage extends StatefulWidget {
  const PdfHistoryPage({super.key});

  @override
  State<PdfHistoryPage> createState() => _PdfHistoryPageState();
}

class _PdfHistoryPageState extends State<PdfHistoryPage> {
  final List _words = ['Diagnosis', 'Dermatology', 'neurology', 'cardiology'];
  List<Map<String, dynamic>> _pdfList = [];
  bool _isLoading = true;
  void getPDFhistoryData() async {
    try {
      // Fetch data from tbl_pdf_data ordered by created_at DESC
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('tbl_pdf_data')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _pdfList = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
        print(_pdfList);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getPDFhistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF History'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total count
                  Text(
                    'Total PDFs: ${_pdfList.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of PDFs
                  Expanded(
                    child: _pdfList.isEmpty
                        ? const Center(
                            child: Text(
                              'No PDFs found.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _pdfList.length,
                            itemBuilder: (context, index) {
                              final pdf = _pdfList[index];
                              final date =
                                  DateTime.parse(pdf['created_at'] as String).toLocal();
                              final formattedDate =
                                  "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} "
                                  "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    'PDF ID: ${pdf['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text('Date-Time: $formattedDate'),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Highlighted words:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children:
                                            (List<String>.from(pdf['col_highlighted_words'])) //get data from database
                                                .take(10)
                                                .map((word) => Chip(
                                                      label: Text(word),
                                                      backgroundColor:
                                                          Colors.blue[50],
                                                    ))
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      final url = pdf['pdf_url'];
                                      if (url != null && url.isNotEmpty) {
                                        web.window.open(url, '_blank');
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('No PDF URL found')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('View'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
