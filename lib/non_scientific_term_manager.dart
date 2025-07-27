import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etymology/services/api_service.dart';

class NonScientificTermManager extends StatefulWidget {
  const NonScientificTermManager({super.key});

  @override
  State<NonScientificTermManager> createState() => _NonScientificTermManagerState();
}

class _NonScientificTermManagerState extends State<NonScientificTermManager> {
  final TextEditingController _controller = TextEditingController();
  String _statusMessage = "";

  Future<void> _addTerm() async {
    final term = _controller.text.trim();
    if (term.isEmpty) return;

    try {
      final success = await ApiService.addNonScientificTerm(term);
      setState(() {
        _statusMessage = success ? "✅ '$term' added." : "❌ '$term' already exists.";
      });
      _controller.clear();
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Non-Scientific Terms"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Non-Scientific Term",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter word like 'the', 'is' etc.",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTerm,
                  child: Text("Add"),
                ),
                 const SizedBox(width: 500),
              ],
            ),
            const SizedBox(height: 15),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.startsWith("✅") ? Colors.green : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
