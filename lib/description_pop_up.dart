import 'package:flutter/material.dart';

class OverlayHelper {
  static OverlayEntry? _entry;
  static void showTooltip({
    required BuildContext context,
    required GlobalKey key,
    required Map<String, dynamic> info,
  }) {
    removeTooltip();
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx,
        top: pos.dy + size.height + 6,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 145,
            height: 160,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
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
                        info['word'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description (Term_Des)
                Text(
                  info['description'] ?? '',
                  style: TextStyle(fontSize: 10),
                ),

                const Divider(height: 20, thickness: 1),

                // Origin
                if (info['origin'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "Origin : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['origin']),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),

                // Prefix
                if (info['prefix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
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

                if (info['suffix'] != null)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10),
                      children: [
                        TextSpan(
                          text: "Suffix : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: info['suffix']),
                      ],
                    ),
                  ),
                // const SizedBox(height: 4),

                // // Term Definition
                // if (info['Term_def'] != null)
                //   Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Image.asset("assets/term_def.png", height: 20, width: 20),
                //       Expanded(
                //         child: Text(
                //           info['Term_def'] ?? '',
                //           style: TextStyle(fontSize: 14),
                //         ),
                //       ),
                //     ],
                //   ),

                // const SizedBox(height: 10),

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
    Overlay.of(context, rootOverlay: true)?.insert(_entry!);
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
    _entry?.remove();
    _entry = null;
  }
}



// Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (info['Medical_Term'] != null) _line("Term", info['Medical_Term']),
//                 if (info['Term_Des'] != null) _line("Description", info['Term_Des']),
//                 Divider(color: Colors.black54),
//                 if (info['Term_origin'] != null) _line("Origin", info['Term_origin']),
//                 if (info['prefix'] != null) _line("Prefix", info['prefix']),
//                 if (info['suffix'] != null) _line("Suffix", info['suffix']),
//                 if (info['Term_def'] != null) _line("Definition", info['Term_def']),
//               ],
//             ),