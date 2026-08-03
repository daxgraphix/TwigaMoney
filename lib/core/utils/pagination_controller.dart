import 'package:flutter/foundation.dart';

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  }) : hasMore = (currentPage * pageSize) < totalCount;

  int get totalPages => (totalCount / pageSize).ceil();
}

class PaginationController<T> extends ChangeNotifier {
  final int pageSize;
  final Future<PaginatedResult<T>> Function(int page, int pageSize) fetcher;

  List<T> items = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  String? error;

  PaginationController({
    this.pageSize = 20,
    required this.fetcher,
  });

  Future<void> loadFirstPage() async {
    currentPage = 0;
    items.clear();
    hasMore = true;
    error = null;
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await fetcher(currentPage + 1, pageSize);
      items.addAll(result.items);
      currentPage = result.currentPage;
      hasMore = result.hasMore;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadFirstPage();
  }
}
