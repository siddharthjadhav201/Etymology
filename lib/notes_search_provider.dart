import 'package:flutter/material.dart';

/// Where a particular search match lives.
enum SearchArea {
  note,
  annotation,
}

/// Immutable (start, end) for a single search match in the main note text.
/// Used only for temporary search highlights inside the editor.
class SearchRange {
  final int start;
  final int end;
  SearchRange(this.start, this.end);
}

/// Navigation target representing either a note match or an annotation match.
class SearchNavigationTarget {
  final bool isNote;
  final SearchRange? noteRange;
  final int? annotationIndex;

  const SearchNavigationTarget._note(this.noteRange)
      : isNote = true,
        annotationIndex = null;

  const SearchNavigationTarget._annotation(this.annotationIndex)
      : isNote = false,
        noteRange = null;
}

class _AnnotationMatch {
  final int annotationIndex;
  final int start;
  final int end;
  _AnnotationMatch(this.annotationIndex, this.start, this.end);
}

/// Isolated provider for "Search Inside Notes" (Ctrl+F style).
/// - Holds temporary search state only; search highlights are not persisted.
class NotesSearchProvider extends ChangeNotifier {
  String _query = '';
  final List<SearchRange> _searchRanges = [];
  final List<_AnnotationMatch> _annotationMatches = [];
  int _currentIndex = 0;

  String get query => _query;
  List<SearchRange> get searchRanges => List.unmodifiable(_searchRanges);
  int get currentIndex => _currentIndex;
  int get matchCount => _searchRanges.length + _annotationMatches.length;

  SearchNavigationTarget? get currentTarget {
    final noteCount = _searchRanges.length;
    final total = noteCount + _annotationMatches.length;
    if (total == 0) return null;

    final idx = _currentIndex.clamp(0, total - 1);
    if (idx < noteCount) {
      return SearchNavigationTarget._note(_searchRanges[idx]);
    } else {
      final annoIdx = idx - noteCount;
      return SearchNavigationTarget._annotation(
          _annotationMatches[annoIdx].annotationIndex);
    }
  }

  /// Call whenever text or query changes to recompute all matches.
  void updateMatches(String text, List<String> annotationTexts,
      {String? newQuery}) {
    if (newQuery != null) {
      _query = newQuery.trim();
    }

    _searchRanges.clear();
    _annotationMatches.clear();

    if (_query.isEmpty) {
      _currentIndex = 0;
      notifyListeners();
      return;
    }

    final q = _query.toLowerCase();

    // 1) Note matches
    if (text.isNotEmpty) {
      final lowerText = text.toLowerCase();
      int start = 0;
      while (true) {
        final i = lowerText.indexOf(q, start);
        if (i == -1) break;
        _searchRanges.add(SearchRange(i, i + q.length));
        start = i + 1;
      }
    }

    // 2) Annotation matches
    for (int idx = 0; idx < annotationTexts.length; idx++) {
      final annoText = annotationTexts[idx];
      if (annoText.isEmpty) continue;
      final lowerAnno = annoText.toLowerCase();
      int start = 0;
      while (true) {
        final i = lowerAnno.indexOf(q, start);
        if (i == -1) break;
        _annotationMatches.add(_AnnotationMatch(idx, i, i + q.length));
        start = i + 1;
      }
    }

    final total = _searchRanges.length + _annotationMatches.length;
    if (_currentIndex >= total) {
      _currentIndex = 0;
    }
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _searchRanges.clear();
    _annotationMatches.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  void next() {
    final total = _searchRanges.length + _annotationMatches.length;
    if (total == 0) return;
    _currentIndex = (_currentIndex + 1) % total;
    notifyListeners();
  }

  void previous() {
    final total = _searchRanges.length + _annotationMatches.length;
    if (total == 0) return;
    _currentIndex = _currentIndex - 1;
    if (_currentIndex < 0) _currentIndex = total - 1;
    notifyListeners();
  }
}
