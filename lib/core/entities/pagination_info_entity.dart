final class PaginationInfoEntity {
  /// The total number of items available across all pages.
  final int total;

  /// The number of items displayed per page.
  final int perPage;

  /// The index of the current page (typically 1-based).
  final int currentPage;

  /// The total number of pages available.
  final int totalPages;

  /// A boolean flag indicating if there are more pages to fetch.
  /// This is the most critical property for implementing "load more" logic.
  final bool hasMorePages;

  const PaginationInfoEntity({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
  });
}
