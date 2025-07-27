import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OverlayHelper {
  static OverlayEntry? _overlayEntry;

  static void showTooltip({
    required BuildContext context,
    required GlobalKey key,
    required Map<String, dynamic> info,
  }) {
    removeTooltip();

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (Medical_Term)
                Row(
                  children: [
                    // Image.asset("assets/medical_term_sign.png",
                    // width: 18,
                    // height: 18,),
                    Expanded(
                      child: Text(
                        info['Medical_Term'] ?? '',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description (Term_Des)
                Text(
                  info['Term_Des'] ?? '',
                  style: TextStyle(fontSize: 14),
                ),

                const Divider(height: 20, thickness: 1),

                // Origin
                if (info['Term_origin'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Origin : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['Term_origin']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),

                // Prefix
                if (info['prefix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Prefix : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['prefix']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),

                // Suffix
                if (info['suffix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Suffix : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['suffix']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),

                // Term Definition
                if (info['Term_def'] != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("assets/term_def.png", height: 20, width: 20),
                      Expanded(
                        child: Text(
                          info['Term_def'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // // Optional footer
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     "More Info",
                //     style: TextStyle(
                //         color: Colors.blue,
                //         fontSize: 12,
                //         fontStyle: FontStyle.italic),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }
  static Widget _line(String label, dynamic val) => Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: val.toString(), style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      );

  static void removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
