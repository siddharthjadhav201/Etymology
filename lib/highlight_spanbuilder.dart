import 'dart:developer';
import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/notes_search_provider.dart';
import 'package:etymology/tapHandler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'providers.dart';

/// Segment type for merged rendering. Word highlight takes precedence over search.
enum _SegmentType { normal, search, word }

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;
  final BuildContext context;
  final TextEditingController controller;
  /// Optional: when set, temporary search highlights are drawn (different color).
  /// Does NOT modify highlightProvider or word highlight data.
  final NotesSearchProvider? notesSearchProvider;

  HighlightSpanBuilder(this.highlightProvider, this.context, this.controller,
      [this.notesSearchProvider]);

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    try {
      final List<InlineSpan> children = [];
      final TapHandler tapHandler = TapHandler();
      // Use List.from so we get List<HighlightedRange>, not List<dynamic> (avoids runtime type error).
      final List<HighlightedRange> highlightedRanges =
          List<HighlightedRange>.from(highlightProvider.highlightedRanges);
      highlightedRanges.sort((a, b) => a.start.compareTo(b.start));

      final List<SearchRange> searchRanges =
          notesSearchProvider?.searchRanges ?? [];
      final SearchRange? activeNoteTarget =
          notesSearchProvider?.currentTarget?.isNote == true
              ? notesSearchProvider?.currentTarget?.noteRange
              : null;
      final List<_MergedSegment> segments =
          _mergeRanges(data.length, highlightedRanges, searchRanges);

      for (final seg in segments) {
        if (seg.type == _SegmentType.normal) {
          children.add(TextSpan(
            text: data.substring(seg.start, seg.end),
            style: textStyle?.copyWith(backgroundColor: null),
          ));
          continue;
        }
        if (seg.type == _SegmentType.search) {
          final bool isActive = activeNoteTarget != null &&
              seg.start >= activeNoteTarget.start &&
              seg.end <= activeNoteTarget.end;
          children.add(TextSpan(
            text: data.substring(seg.start, seg.end),
            style: textStyle?.copyWith(
              backgroundColor: isActive
                  ? Colors.cyan.withAlpha(190)
                  : Colors.cyan.withAlpha(100),
            ),
          ));
          continue;
        }
        // seg.type == _SegmentType.word — existing word highlight (unchanged)
        final highlightedWordsLocation = seg.highlightedRange!;
        final String word = data
            .substring(highlightedWordsLocation.start, highlightedWordsLocation.end)
            .toLowerCase();
        final bool isAnnotated = highlightProvider.isAnnotated;
        if (isAnnotated) {
          children.add(TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTapDown = (details) {
                tapHandler.handleTapDown(
                  details: details,
                  onSingleTap: () {
                    Map<String, dynamic> info =
                        highlightProvider.highlightWordsData[word] ?? {
                      "medical_term": word,
                      "meaning": "Information currently unavailable"
                    };
                    print(
                        " Single Tap Detected at ${details.globalPosition}");
                    highlightProvider.insertDescriptionPopUp(
                        context, details.globalPosition, info);
                  },
                  onDoubleTap: () async {
                    print(
                        " Double Tap Detected at ${details.globalPosition}");
                    await highlightProvider.changeEditorFocusState;
                    controller.selection = TextSelection(
                        baseOffset: highlightedWordsLocation.start,
                        extentOffset: highlightedWordsLocation.end);
                  },
                );
              },
            text: data.substring(
                highlightedWordsLocation.start, highlightedWordsLocation.end),
            style: textStyle?.copyWith(
                backgroundColor: Colors.yellow.withAlpha(128)),
          ));
        } else {
          children.add(TextSpan(
            text: data.substring(
                highlightedWordsLocation.start, highlightedWordsLocation.end),
            style: textStyle?.copyWith(
                backgroundColor: Colors.yellow.withAlpha(128)),
          ));
        }
      }

      return TextSpan(children: children, style: textStyle);
    } catch (e) {
      log("***error in rendering : $e");
      return TextSpan();
    }
  }

  /// Merges word highlights and search highlights into non-overlapping segments.
  /// Word highlight takes precedence over search where they overlap.
  /// Does NOT modify highlightProvider.highlightedRanges or wordLocations.
  List<_MergedSegment> _mergeRanges(
      int dataLength,
      List<HighlightedRange> wordRanges,
      List<SearchRange> searchRanges) {
    final Set<int> boundaries = {};
    for (final r in wordRanges) {
      boundaries.add(r.start);
      boundaries.add(r.end);
    }
    for (final r in searchRanges) {
      boundaries.add(r.start);
      boundaries.add(r.end);
    }
    boundaries.add(0);
    boundaries.add(dataLength);
    final sorted = boundaries.toList()..sort();
    final List<_MergedSegment> out = [];
    for (int i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];
      if (a >= b) continue;
      bool inWord = false;
      for (final r in wordRanges) {
        if (r.start <= a && b <= r.end) {
          inWord = true;
          break;
        }
      }
      if (inWord) {
        final wordRange = wordRanges.firstWhere((r) => r.start <= a && b <= r.end);
        out.add(_MergedSegment(a, b, _SegmentType.word, wordRange));
        continue;
      }
      bool inSearch = false;
      for (final r in searchRanges) {
        if (r.start <= a && b <= r.end) {
          inSearch = true;
          break;
        }
      }
      if (inSearch) {
        out.add(_MergedSegment(a, b, _SegmentType.search, null));
      } else {
        out.add(_MergedSegment(a, b, _SegmentType.normal, null));
      }
    }
    return out;
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    throw UnimplementedError();
  }
}

class _MergedSegment {
  final int start;
  final int end;
  final _SegmentType type;
  final HighlightedRange? highlightedRange;
  _MergedSegment(this.start, this.end, this.type, this.highlightedRange);
}