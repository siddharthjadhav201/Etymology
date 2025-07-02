import 'package:flutter/services.dart';

class HighlightBlockFormatter extends TextInputFormatter {
  final List<HighlightedRange> blockedRanges;

  HighlightBlockFormatter(this.blockedRanges);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    for (final range in blockedRanges) {
      if (_hasIntersection(range, oldValue.selection, newValue.selection)) {
        // Prevent change
        return oldValue;
      }
    }
    return newValue;
  }

  bool _hasIntersection(
    HighlightedRange range,
    TextSelection oldSelection,
    TextSelection newSelection,
  ) {
    final editingRange = TextRange(start: oldSelection.start, end: newSelection.end);
    return !(editingRange.end <= range.start || editingRange.start >= range.end);
  }
}

class HighlightedRange {
  final int start;
  final int end;

  HighlightedRange(this.start, this.end);
}
