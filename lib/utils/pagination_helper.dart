import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PaginationHelper<T> {
  final String collection;
  final String orderByField;
  final bool descending;
  final int pageSize;
  final T Function(Map<String, dynamic> data, String id) fromMap;
  final Query<Map<String, dynamic>>? Function()? customQuery;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  List<T> _items = [];
  String? _error;

  PaginationHelper({
    required this.collection,
    required this.orderByField,
    required this.fromMap,
    this.descending = true,
    this.pageSize = 10,
    this.customQuery,
  });

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;

    try {
      Query<Map<String, dynamic>> query;

      if (customQuery != null) {
        final custom = customQuery!();
        if (custom == null) {
          query = FirebaseFirestore.instance.collection(collection);
        } else {
          query = custom;
        }
      } else {
        query = FirebaseFirestore.instance.collection(collection);
      }

      query = query.orderBy(orderByField, descending: descending);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(pageSize);

      final snapshot = await query.get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = docs.last;
        final newItems = docs.map((doc) {
          return fromMap(doc.data(), doc.id);
        }).toList();

        _items.addAll(newItems);

        if (docs.length < pageSize) {
          _hasMore = false;
        }
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('PaginationHelper error: $e\n$stackTrace');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _lastDocument = null;
    _hasMore = true;
    _items.clear();
    _error = null;
    await loadMore();
  }

  void clear() {
    _lastDocument = null;
    _hasMore = true;
    _items.clear();
    _error = null;
    _isLoading = false;
  }
}

class PaginatedListView<T> extends StatefulWidget {
  final PaginationHelper<T> paginationHelper;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final RefreshCallback? onRefresh;

  const PaginatedListView({
    super.key,
    required this.paginationHelper,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.padding,
    this.scrollController,
    this.onRefresh,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    // İlk yükleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.paginationHelper.isEmpty &&
          !widget.paginationHelper.isLoading) {
        widget.paginationHelper.loadMore().then((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.paginationHelper.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await widget.paginationHelper.loadMore();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await widget.paginationHelper.refresh();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final helper = widget.paginationHelper;

    if (helper.error != null && helper.isEmpty) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Hata: ${helper.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await helper.refresh();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
    }

    if (helper.isLoading && helper.isEmpty) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (helper.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        itemCount: helper.items.length + (helper.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= helper.items.length) {
            // Loading indicator at the bottom
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return widget.itemBuilder(context, helper.items[index], index);
        },
      ),
    );
  }
}
