import 'package:etymology/notes_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Small search bar for "Search Inside Notes" (Ctrl+F style).
/// Renders above the notes editor; does not modify highlight or PDF logic.
class NotesSearchBar extends StatefulWidget {
  final TextEditingController noteController;

  /// Lazily provides current annotation texts (meanings) for search.
  final List<String> Function() annotationTextsBuilder;

  /// Called after navigation (next/previous) with the resolved target
  /// so the parent can scroll/jump appropriately.
  final void Function(SearchNavigationTarget target) onNavigate;

  /// Optional: use shared controller/focus so inline and floating bar stay in sync.
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;

  /// When true, request focus on the search field after first frame (e.g. when floating bar opens).
  final bool requestFocusOnMount;

  const NotesSearchBar({
    super.key,
    required this.noteController,
    required this.annotationTextsBuilder,
    required this.onNavigate,
    this.searchController,
    this.searchFocusNode,
    this.requestFocusOnMount = false,
  });

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  TextEditingController? _internalSearchController;
  FocusNode? _internalFocusNode;

  bool get _ownsController => widget.searchController == null;
  TextEditingController get _searchController =>
      widget.searchController ?? _internalSearchController!;
  FocusNode get _searchFocusNode =>
      widget.searchFocusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (_ownsController) {
      _internalSearchController = TextEditingController();
      _internalFocusNode = FocusNode();
    }
    if (widget.requestFocusOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(NotesSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requestFocusOnMount && !oldWidget.requestFocusOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _internalSearchController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesSearchProvider>(
      builder: (context, searchProvider, _) {
        final hasQuery = searchProvider.query.isNotEmpty;
        final count = searchProvider.matchCount;
        final index = searchProvider.currentIndex;
        final showCounter = hasQuery && count > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Type and enter..',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      searchProvider.updateMatches(
                        widget.noteController.text,
                        widget.annotationTextsBuilder(),
                        newQuery: value,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Counter
              if (showCounter)
                Text(
                  '${index + 1} of $count',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              if (showCounter) const SizedBox(width: 4),
              // Navigation arrows
              if (count > 0) ...[
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                  tooltip: 'Previous result',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    // Update matches to ensure navigation targets are stable
                    searchProvider.updateMatches(
                      widget.noteController.text,
                      widget.annotationTextsBuilder(),
                    );
                    searchProvider.previous();
                    final target = searchProvider.currentTarget;
                    if (target != null) {
                      widget.onNavigate(target);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  tooltip: 'Next result',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    // Update matches to ensure navigation targets are stable
                    searchProvider.updateMatches(
                      widget.noteController.text,
                      widget.annotationTextsBuilder(),
                    );
                    searchProvider.next();
                    final target = searchProvider.currentTarget;
                    if (target != null) {
                      widget.onNavigate(target);
                    }
                  },
                ),
              ],
              // Clear button
              if (hasQuery) const SizedBox(width: 4),
              if (hasQuery)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: 'Clear search',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    _searchController.clear();
                    searchProvider.clearSearch();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
