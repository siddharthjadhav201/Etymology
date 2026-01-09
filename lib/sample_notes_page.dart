import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class SampleNotesPage extends StatelessWidget {
  const SampleNotesPage({super.key});

  final List<Map<String, String>> samples = const [
    {
      'image': 'assets/anatomy.png',
      'pdf': 'assets/Introduction to Animal Eye Anatomy.pdf',
      'title': 'Animal Eye Anatomy',
    },
    {
      'image': 'assets/botany.png',
      'pdf': 'assets/Introduction to Botany.pdf',
      'title': 'Introduction to Botany',
    },
    {
      'image': 'assets/cell_biology.png',
      'pdf': 'assets/Fundamental Concepts in Cell Biology.pdf',
      'title': 'Cell Biology Concepts',
    },
    {
      'image': 'assets/heart_anatomy.png',
      'pdf': 'assets/Introduction to Heart Anatomy and Physiology.pdf',
      'title': 'Heart Anatomy',
    },
    {
      'image': 'assets/inflammation.png',
      'pdf': 'assets/Introduction to Inflammation and repair.pdf',
      'title': 'Inflammation & Repair',
    },
    {
      'image': 'assets/skin_histrology.png',
      'pdf': 'assets/Introduction to Skin Histology.pdf',
      'title': 'Skin Histology',
    },
  ];

  Future<void> _downloadFile(
      BuildContext context, String assetPath, String fileName) async {
    try {
      if (kIsWeb) {
        // Web: Download using AnchorElement
        final bytes = await rootBundle.load(assetPath);
        final blob = html.Blob([bytes.buffer.asUint8List()], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop: Save to temporary directory and open
        final byteData = await rootBundle.load(assetPath);
        final file = File('${(await getTemporaryDirectory()).path}/$fileName');
        await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        await OpenFile.open(file.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // Responsive grid count based on width
    int crossAxisCount =
        width > 1200 ? 4 : (width > 800 ? 3 : (width > 600 ? 2 : 1));
    double childAspectRatio = 0.75;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sample Notes",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore Our Curated Samples",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Download quality PDF notes to kickstart your learning journey.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: samples.length,
                itemBuilder: (context, index) {
                  final item = samples[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Container(
                              width: double.infinity,
                              color: Color(0xFFF3F4F6),
                              padding: const EdgeInsets.all(16),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.contain,
                                errorBuilder: (c, o, s) => const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final fileName = item['pdf']!.split('/').last;
                                _downloadFile(context, item['pdf']!, fileName);
                              },
                              icon:
                                  const Icon(Icons.download_rounded, size: 18),
                              label: Text(
                                "Download PDF",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
