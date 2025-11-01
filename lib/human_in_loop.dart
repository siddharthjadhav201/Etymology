// lib/pages/medical_terms_etymo_page.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalTermsEtymoPage extends StatefulWidget {
  const MedicalTermsEtymoPage({super.key});

  @override
  State<MedicalTermsEtymoPage> createState() => _MedicalTermsEtymoPageState();
}

class _MedicalTermsEtymoPageState extends State<MedicalTermsEtymoPage> {
  //  CONFIG

  bool autoRefreshOnSave = true; // toggle: if true, fetchWords() after save

  //  STATE
  String selectedLetter = 'A';
  int currentPage = 1;
  int totalPages = 1;
  List<Map<String, dynamic>> terms = [];
  bool isLoading = false;
  late ScrollController _scrollController;
  final List<GlobalKey> _itemKeys = [];

  Map<String, dynamic>? selectedTerm;
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController addTermController = TextEditingController();
  final TextEditingController addMeaningController = TextEditingController();
  var supabase = Supabase.instance.client;

  // final Set<int> updatedIds = {};
  @override
  void initState() {
    super.initState();
    fetchWords();
    _scrollController = ScrollController();
  }

  //  FETCH PAGINATED TERMS
  Future<void> fetchWords() async {
    if (selectedLetter.isEmpty) return;
    setState(() {
      isLoading = true;
      selectedTermIndex = null; // reset selection on fetch
      selectedTerm = null;
      meaningController.clear();
    });

    try {
      final responseWithCount = await supabase
          .from('tbl_medical_terms')
          .select('*')
          .ilike('medical_term', '$selectedLetter%')
          .count(CountOption.exact);
      final dataForChar = await supabase
          .from('tbl_medical_terms')
          .select('id,medical_term,meaning,term_edited')
          .ilike('medical_term', '$selectedLetter%')
          .order('medical_term', ascending: true)
          .range((currentPage - 1) * 50, (currentPage - 1) * 50 + 50);
      setState(() {
        terms = dataForChar;
        _itemKeys
          ..clear()
          ..addAll(List.generate(terms.length, (_) => GlobalKey()));
        totalPages = responseWithCount.count % 50 == 0
            ? responseWithCount.count ~/ 50
            : responseWithCount.count ~/ 50 + 1;
      });
    } catch (e, st) {
      debugPrint('fetchWords -> error: $e\n$st');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // -------------tranfer term--------------------
  Future<void> transferTerm(String term, String meaning) async {
    try {
      final dataForChar = await supabase
          .from('tbl_non_scientefic_terms')
          .insert({'medical_term': term, 'meaning': meaning});
      final response = await supabase
          .from('tbl_medical_terms')
          .delete()
          .eq('medical_term', term);

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
    } catch (e) {
      debugPrint('transferTerm error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error transferring term')),
      );
    }
  }

  //------------ Delete term ---------------------
  Future<void> deleteTerm(String term) async {
    try {
      final response = await supabase
          .from('tbl_medical_terms')
          .delete()
          .eq('medical_term', term);

      debugPrint('Deleted: $response');

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
    } catch (e) {
      debugPrint('deleteTerm error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  // ---------- SEARCH (exact match endpoint) ----------

  Future<void> searchWord() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final dataForChar = await supabase
          .from('tbl_medical_terms')
          .select('id,medical_term,meaning,term_edited')
          .ilike('medical_term', query);

      if (dataForChar.isNotEmpty) {
        setState(() {
          selectedTerm = dataForChar[0];
          meaningController.text = dataForChar[0]['meaning'] ?? '';
          // optionally show the single result in list:
          terms = [dataForChar[0]];
          currentPage = 1;
          totalPages = 1;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Word not found')));
      }
    } catch (e, st) {
      debugPrint('searchWord -> error: $e\n$st');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------- UPDATE MEANING ----------

  Future<void> updateMeaning(String term, int index) async {
  if (meaningController.text.isEmpty) {
    return;
  }
  try {
    await supabase
        .from('tbl_medical_terms')
        .update({'meaning': meaningController.text, 'term_edited': true})
        .eq('medical_term', term);

    // keep a copy of the updated term
    final updatedTerm = term;

    setState(() {
      terms[index]['meaning'] = meaningController.text;
      terms[index]['term_edited'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updated successfully')),
    );

    // if auto-refresh is enabled, reload the list
    if (autoRefreshOnSave) {
      await fetchWords();

      // ✅ after fetch, restore selection
      final restoredIndex =
          terms.indexWhere((t) => t['medical_term'] == updatedTerm);

      if (restoredIndex != -1) {
        setState(() {
          selectedTermIndex = restoredIndex;
          meaningController.text = terms[restoredIndex]['meaning'] ?? '';
        });

        // scroll to it
         WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _itemKeys[restoredIndex].currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.3,
            );
          } else {
            // fallback: scroll manually using controller
            final offset = (restoredIndex * 54.0).clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            );
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  } catch (e) {
    debugPrint('updateMeaning -> error: $e');
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Update failed')));
  }
}


  // ---------- UI Helpers ----------
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
              child: Text(
                letter,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    );
  }

  int? selectedTermIndex; // keep track of which word is expanded

  Widget _wordList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (terms.isEmpty) return const Center(child: Text('No words found'));

    return RefreshIndicator(
      onRefresh: fetchWords,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: terms.length,
        itemBuilder: (context, index) {
          final term = terms[index];
          final edited = term['term_edited'] == true;
          final isSelected = selectedTermIndex == index;

          return Container(
            key: _itemKeys[index],
            color: isSelected ? Colors.green.shade100 : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(term['medical_term'][0].toUpperCase() +
                          term['medical_term'].substring(1).toLowerCase() ??
                      ''),
                  subtitle: edited ? const Text('Refined') : null,
                  onTap: () {
                    setState(() {
                      selectedTermIndex = index;
                      meaningController.text = term['meaning'] ?? '';
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Checkbox instead of green background
                      Checkbox(
                        value: edited,
                        onChanged: (_) {},
                        activeColor: Colors.green.shade400,
                        checkColor: Colors.white,
                      ),
                      const SizedBox(width: 8),

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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Transfer')),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await transferTerm(
                                term['medical_term'], term['meaning']);

                            if (index < terms.length - 1) {
                              setState(() {
                                selectedTermIndex =
                                    index; // ✅ move to NEXT word
                                meaningController.text =
                                    terms[index]['meaning'] ?? '';
                              });

                              // auto-scroll to next term
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final context =
                                    _itemKeys[index + 1].currentContext;
                                if (context != null) {
                                  Scrollable.ensureVisible(
                                    context,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              });
                            } else {
                              setState(() {
                                selectedTermIndex = null; // no next word
                              });
                            }

                            // 🔹 Step 4: scroll to the next word if it exists
                            if (index < terms.length) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  index *
                                      52.0, // adjust tile height if different
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          }

                          // if (confirm == true) {
                          //   await transferTerm(
                          //       term['medical_term'], term['meaning']);

                          //   // ✅ Auto-open next word
                          //   if (index < terms.length ) {
                          //     setState(() {
                          //       terms.removeAt(index);
                          //       selectedTermIndex = index;
                          //       meaningController.text =
                          //           terms[index]['meaning'] ?? '';
                          //     });
                          //   } else {
                          //     setState(() {
                          //       selectedTermIndex = null;
                          //     });
                          //   }
                          // }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(
                                    1, 1), // horizontal & vertical shadow
                              ),
                            ],
                          ),
                          child: const Text(
                            "Transfer",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Expanded editor under the word
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: meaningController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Meaning",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final updatedMeaning = meaningController.text;
                            await updateMeaning(term['medical_term'], index);

                            setState(() {
                              terms[index]['meaning'] = updatedMeaning;
                              terms[index]['term_edited'] = true;
                            });

                            
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 6, // shadow depth
                            shadowColor: Colors.black54, // shadow color
                            backgroundColor: Colors.blue.shade50,
                            fixedSize: Size(120, 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Update",
                            style: TextStyle(
                                color: Colors.indigo,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _paginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(width: 12),
        Text('Page $currentPage of $totalPages'),
        const SizedBox(width: 12),
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
      ],
    );
  }

  Future<void> addTerm() async {
    final String term = addTermController.text.trim();
    final String meaning = addMeaningController.text.trim();
    if (term.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provide term and meaning')),
      );
      return;
    }
    try {
      log(term);
      log(meaning);
      final dataForChar = await supabase
          .from('tbl_medical_terms')
          .insert({'medical_term': term, 'meaning': meaning});
      log('${dataForChar}');
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
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Term already exists')),
        );
      }
      debugPrint('addTerm error: ${e.code}');
    } catch (e) {
      debugPrint('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add failed: $e')),
      );
    }
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

  @override
  void dispose() {
    meaningController.dispose();
    searchController.dispose();
    addTermController.dispose();
    addMeaningController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.navigate_before,
              color: Colors.white,
            )),
        title: const Text(
          'Refine Medical Terms Description',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        // actions: [
        //   Row(
        //     children: [
        //       const Text('Auto-refresh', style: TextStyle(color: Colors.white)),
        //       Switch(
        //         value: autoRefreshOnSave,
        //         onChanged: (v) => setState(() => autoRefreshOnSave = v),
        //       ),
        //       const SizedBox(width: 8),
        //     ],
        //   ),
        // ],
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
          // if (selectedTerm != null)
          //   Container(
          //     color: Colors.yellow[50],
          //     padding: const EdgeInsets.all(12),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         Text('Human in Loop Update: ${selectedTerm!['medical_term']}',
          //             style: const TextStyle(fontWeight: FontWeight.bold)),
          //         const SizedBox(height: 8),
          //         TextField(
          //           controller: meaningController,
          //           maxLines: 4,
          //           decoration: const InputDecoration(
          //             border: OutlineInputBorder(),
          //             labelText: 'Meaning',
          //           ),
          //         ),
          //         const SizedBox(height: 8),
          //         ElevatedButton(
          //           onPressed: () =>
          //               updateMeaning(selectedTerm!['medical_term'] as String),
          //           child: const Text('Save'),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
