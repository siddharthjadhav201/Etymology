import "package:flutter/material.dart";




void showPopupAtFixedPosition(BuildContext context, Offset position, String text) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(text, style: TextStyle(fontSize: 16)),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // Auto-close after 2 seconds
  Future.delayed(Duration(seconds: 2), () => entry.remove());
}