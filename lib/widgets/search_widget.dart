import 'package:flutter/material.dart';
import 'dart:async';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final Duration debounceTime;
  final bool autofocus;
  final TextEditingController? controller;

  const SearchWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Ara...',
    this.onClear,
    this.debounceTime = const Duration(milliseconds: 500),
    this.autofocus = false,
    this.controller,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      widget.onSearch(_controller.text.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(color: scheme.onSurface, fontSize: 14),
      ),
    );
  }
}

class SearchableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool Function(T item, String query) searchFilter;
  final String searchHint;
  final Widget? emptyWidget;
  final Widget? noResultsWidget;
  final EdgeInsets? padding;

  const SearchableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchFilter,
    this.searchHint = 'Ara...',
    this.emptyWidget,
    this.noResultsWidget,
    this.padding,
  });

  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  String _searchQuery = '';
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filterItems(_searchQuery);
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.searchFilter(item, query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48),
                SizedBox(height: 16),
                Text('Henüz veri yok'),
              ],
            ),
          );
    }

    return Column(
      children: [
        Padding(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: SearchWidget(
            hintText: widget.searchHint,
            onSearch: _filterItems,
          ),
        ),
        Expanded(
          child: _filteredItems.isEmpty && _searchQuery.isNotEmpty
              ? widget.noResultsWidget ??
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48),
                          const SizedBox(height: 16),
                          Text('Arama sonucu bulunamadı: "$_searchQuery"'),
                        ],
                      ),
                    )
              : ListView.builder(
                  padding: widget.padding,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return widget.itemBuilder(
                      context,
                      _filteredItems[index],
                      index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
