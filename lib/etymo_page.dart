// lib/pages/medical_terms_etymo_page.dart
import 'dart:convert';
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

  Map<String, dynamic>? selectedTerm;
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  var supabase = Supabase.instance.client;
  

  // final Set<int> updatedIds = {};
  @override
  void initState() {
    super.initState();
    fetchWords(); 
  }

  //  FETCH PAGINATED TERMS 
  Future<void> fetchWords() async {
    if (selectedLetter.isEmpty) return;
    setState(() => isLoading = true);

    try {
final responseWithCount = await supabase.from('medical_terms_new').select('*').ilike('medical_term', '$selectedLetter%').count(CountOption.exact);
print(responseWithCount.count);
         final dataForChar=await supabase.from('medical_terms_new').select('id,medical_term,meaning,term_edited').ilike('medical_term', '$selectedLetter%').order('medical_term', ascending: true).range((currentPage-1)*50, (currentPage-1)*50+50);
        setState(() {
          terms = dataForChar;
          totalPages = responseWithCount.count%50==0?responseWithCount.count~/50:responseWithCount.count~/50+1;
          print(terms.length);
        });
    } catch (e, st) {
      debugPrint('fetchWords -> error: $e\n$st');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------- SEARCH (exact match endpoint) ----------


  Future<void> searchWord() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => isLoading = true);
    
    

    try {
      
    final dataForChar=await supabase.from('medical_terms_new').select('id,medical_term,meaning,term_edited').ilike('medical_term', query);
      
      if (dataForChar.isNotEmpty) {
        setState(() {
          selectedTerm = dataForChar[0];
          meaningController.text = dataForChar[0]['meaning'] ?? '';
          // optionally show the single result in list:
          terms = [dataForChar[0]];
          currentPage = 1;
          totalPages = 1;
        });
      } else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Word not found')));
      }
    } catch (e, st) {
      debugPrint('searchWord -> error: $e\n$st');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------- UPDATE MEANING ----------


  Future<void> updateMeaning(id) async {
   
    if(meaningController.text.isEmpty){return;}
    try {
  var res=await supabase
  .from('medical_terms_new')
  .update({ 'meaning': meaningController.text ,'term_edited':true})
  .eq('medical_term',selectedTerm!['medical_term']);

        setState(() {
            // updatedIds.add(id);
            selectedTerm!['meaning'] = meaningController.text;
            selectedTerm!['term_edited']=true;
          
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully')));

        // Auto-refresh behaviour: if enabled, re-fetch list so paging/ordering is consistent
        if (autoRefreshOnSave) {
          await fetchWords();
        }
      
    } catch (e, st) {
      debugPrint('updateMeaning -> error: $e\n$st');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update error')));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));

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
              child: Text(letter,
              style: TextStyle(
                fontWeight: FontWeight.w600
              ),),
            ),
          );
        }),
      ),
    );
  }

  Widget _wordList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (terms.isEmpty) {
      return const Center(child: Text('No words found'));
    }

    return RefreshIndicator(
      onRefresh: fetchWords, // manual pull-to-refresh
      child: ListView.builder(
        itemCount: terms.length,
        itemBuilder: (context, index) {
          print(index);
          final term = terms[index];
          // final isUpdated = updatedIds.contains(term['id']);
          return ListTile(
            title: Text(term['medical_term'] ?? ''),
            subtitle: term['term_edited'] ? const Text('Refined') : null,
            tileColor: term['term_edited'] ? Colors.green[100] : null,
            onTap: () {
              setState((){
                selectedTerm = Map<String, dynamic>.from(term);
                meaningController.text = selectedTerm!['meaning'] ?? '';
              });
            },
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
          onPressed: currentPage > 1 ? () { setState(() { currentPage--; selectedTerm=null; }); fetchWords(); } : null,
          child: const Text('Prev'),
        ),
        const SizedBox(width: 12),
        Text('Page $currentPage of $totalPages'),
        const SizedBox(width: 12),
        TextButton(
          onPressed: currentPage < totalPages ? () { setState(() { currentPage++; selectedTerm=null; }); fetchWords(); } : null,
          child: const Text('Next'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    meaningController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refine Medical Terms Description',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,

        ),),
        // actions: [
        //   Row(
        //     children: [
        //       const Text('Auto-refresh after save',
        //       style: TextStyle(
        //   color: Colors.white,
        //   ),
        //   ),
        //       Switch(
        //         activeColor: Colors.green.shade300 ,
        //         value: autoRefreshOnSave,
        //         onChanged: (v) => setState(() => autoRefreshOnSave = v),
        //       ),
        //     ],
        //   ),
        // ],
        backgroundColor: const Color(0xFF363BBA),
      ),
      body: Column(
        children: [
          // Search bar
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
              ElevatedButton(onPressed: searchWord, child: const Text('Search',
              )),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: fetchWords,
                child: const Text('Refresh'), // manual refresh button
              ),
            ]),
          ),

          // Letters
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _letterButtons()),

          // List
          Expanded(child: _wordList()),

          // Pagination
          _paginationControls(),

          // Editor
          if (selectedTerm != null)
            Container(
              color: Colors.yellow[50],
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Human in Loop Update: ${selectedTerm!['medical_term']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: meaningController,
                    maxLines: 4,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Meaning'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final id = selectedTerm!['id'] as int;
                      updateMeaning(id);
                    },
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
