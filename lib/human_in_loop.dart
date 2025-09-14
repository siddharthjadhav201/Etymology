import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicalTermsEtymoPage extends StatefulWidget {
  const MedicalTermsEtymoPage({super.key});

  @override
  State<MedicalTermsEtymoPage> createState() => _MedicalTermsEtymoPageState();
}

class _MedicalTermsEtymoPageState extends State<MedicalTermsEtymoPage> {
  // CONFIG
  final String baseUrl = 'http://localhost:3000';
  bool autoRefreshOnSave = true;

  // STATE
  String selectedLetter = 'A';
  int currentPage = 1;
  int totalPages = 1;
  List<Map<String, dynamic>> terms = [];
  bool isLoading = false;

  Map<String, dynamic>? selectedTerm;
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController addTermController = TextEditingController();
  final TextEditingController addMeaningController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  Future<void> fetchWords() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
          '$baseUrl/etymo-terms/${selectedLetter.toUpperCase()}/$currentPage');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        final List<dynamic> rows = data['words'] ?? [];
        setState(() {
          terms = rows.map((e) => Map<String, dynamic>.from(e)).toList();
          totalPages = (data['totalPages'] ?? 1) as int;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetch failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('fetchWords error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> searchWord() async {
    final q = searchController.text.trim();
    if (q.isEmpty) return;
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
          '$baseUrl/etymo-terms/search?word=${Uri.encodeQueryComponent(q)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          selectedTerm = data;
          meaningController.text = data['meaning'] ?? '';
          terms = [data]; // show single result
          currentPage = 1;
          totalPages = 1;
        });
      } else if (res.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('searchWord error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateMeaning(String term) async {
    final payload = {'meaning': meaningController.text};
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/etymo-terms/${Uri.encodeComponent(term)}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (res.statusCode == 200) {
        // Update local state
        setState(() {
          if (selectedTerm != null && selectedTerm!['medical_term'] == term) {
            selectedTerm!['meaning'] = meaningController.text;
            selectedTerm!['term_edited'] = true;
          }
          final idx = terms.indexWhere((t) => t['medical_term'] == term);
          if (idx != -1) {
            terms[idx]['meaning'] = meaningController.text;
            terms[idx]['term_edited'] = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated')),
        );
        if (autoRefreshOnSave) await fetchWords();
      } else if (res.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Term not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('updateMeaning error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update error')),
      );
    }
  }

  Future<void> transferTerm(String term) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/words/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'word': term}),
      );
      if (res.statusCode == 200) {
        setState(() {
          terms.removeWhere((t) => t['medical_term'] == term);
          if (selectedTerm != null && selectedTerm!['medical_term'] == term) {
            selectedTerm = null;
            meaningController.clear();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transferred $term')),
        );
        await fetchWords();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('transferTerm error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error transferring term')),
      );
    }
  }

  Future<void> deleteTerm(String term) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/etymo-terms/${Uri.encodeComponent(term)}'),
      );
      if (res.statusCode == 200) {
        setState(() {
          terms.removeWhere((t) => t['medical_term'] == term);
          if (selectedTerm != null && selectedTerm!['medical_term'] == term) {
            selectedTerm = null;
            meaningController.clear();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted')),
        );
        // refresh page to keep pagination consistent
        await fetchWords();
      } else if (res.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Term not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('deleteTerm error: $e');
    }
  }

  Future<void> addTerm() async {
    final term = addTermController.text.trim();
    final meaning = addMeaningController.text.trim();
    if (term.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provide term and meaning')),
      );
      return;
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/etymo-terms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'medical_term': term, 'meaning': meaning}),
      );
      if (res.statusCode == 201) {
        Navigator.of(context).pop(); // close dialog
        addTermController.clear();
        addMeaningController.clear();
        // If the new term starts with the chosen letter, refresh
        if (term.toUpperCase().startsWith(selectedLetter.toUpperCase())) {
          await fetchWords();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added')),
        );
      } else if (res.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Term already exists')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('addTerm error: $e');
    }
  }

  Widget _letterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(26, (i) {
          final letter = String.fromCharCode(65 + i);
          final isSelected = selectedLetter == letter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedLetter = letter;
                  currentPage = 1;
                  selectedTerm = null;
                });
                fetchWords();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black,
              ),
              child: Text(letter,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
        }),
      ),
    );
  }

  Widget _pageNumberRow() {
    // show up to 15 page buttons around current page
    const maxButtons = 15;
    final start = (currentPage - (maxButtons ~/ 2)).clamp(1, totalPages);
    final end = (start + maxButtons - 1).clamp(1, totalPages);
    final pages = [for (int p = start; p <= end; p++) p];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          TextButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      selectedTerm = null;
                    });
                    fetchWords();
                  }
                : null,
            child: const Text('Prev'),
          ),
          ...pages.map((p) {
            final selected = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected ? Colors.blue : null,
                  foregroundColor: selected ? Colors.white : null,
                ),
                onPressed: () {
                  setState(() {
                    currentPage = p;
                    selectedTerm = null;
                  });
                  fetchWords();
                },
                child: Text('$p'),
              ),
            );
          }),
          TextButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      selectedTerm = null;
                    });
                    fetchWords();
                  }
                : null,
            child: const Text('Next'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('Page $currentPage of $totalPages'),
          ),
        ],
      ),
    );
  }

  Widget _wordList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (terms.isEmpty) return const Center(child: Text('No words found'));

    return RefreshIndicator(
      onRefresh: fetchWords,
      child: ListView.builder(
        itemCount: terms.length,
        itemBuilder: (context, index) {
          final term = terms[index];
          final edited = term['term_edited'] == true;
          return ListTile(
            tileColor: edited ? Colors.green[100] : null,
            title: Text(term['medical_term'] ?? ''),
            subtitle: edited ? const Text('Refined') : null,
            onTap: () {
              setState(() {
                selectedTerm = Map<String, dynamic>.from(term);
                meaningController.text = selectedTerm!['meaning'] ?? '';
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Transfer button
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Transfer term?'),
                        content: Text(
                            'Move "${term['medical_term']}" to non-scientific terms?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Transfer')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await transferTerm(term['medical_term']);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Transfer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                // GestureDetector(
                //   onTap: () async {
                //     final confirm = await showDialog<bool>(
                //       context: context,
                //       builder: (_) => AlertDialog(
                //         title: const Text('Delete term?'),
                //         content: Text('Delete "${term['medical_term']}"?'),
                //         actions: [
                //           TextButton(
                //               onPressed: () => Navigator.pop(context, false),
                //               child: const Text('Cancel')),
                //           TextButton(
                //               onPressed: () => Navigator.pop(context, true),
                //               child: const Text('Delete')),
                //         ],
                //       ),
                //     );
                //     if (confirm == true) {
                //       await deleteTerm(term['medical_term']);
                //     }
                //   },
                //   child: Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.red,
                //       borderRadius: BorderRadius.circular(6),
                //     ),
                //     child: const Text(
                //       "Delete",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Term'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addTermController,
              decoration: const InputDecoration(labelText: 'Medical term'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addMeaningController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Meaning'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(onPressed: addTerm, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    meaningController.dispose();
    searchController.dispose();
    addTermController.dispose();
    addMeaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refine Medical Terms Description'),
        actions: [
          Row(
            children: [
              const Text('Auto-refresh', style: TextStyle(color: Colors.white)),
              Switch(
                value: autoRefreshOnSave,
                onChanged: (v) => setState(() => autoRefreshOnSave = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        backgroundColor: const Color(0xFF363BBA),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search + Refresh
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search word...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => searchWord(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: searchWord, child: const Text('Search')),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: fetchWords, child: const Text('Refresh')),
            ]),
          ),

          // Letters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _letterButtons(),
          ),

          // Page numbers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: _pageNumberRow(),
          ),

          // List
          Expanded(child: _wordList()),

          // Editor
          if (selectedTerm != null)
            Container(
              color: Colors.yellow[50],
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Human in Loop Update: ${selectedTerm!['medical_term']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: meaningController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Meaning',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        updateMeaning(selectedTerm!['medical_term'] as String),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
