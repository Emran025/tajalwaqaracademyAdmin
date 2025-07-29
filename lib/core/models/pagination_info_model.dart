import 'package:flutter/foundation.dart';

/// A data model that encapsulates pagination metadata from an API response.
///
/// This immutable value object is used to understand the state of a paginated
/// collection, such as the total number of items, the current page, and whether
/// more data is available to be fetched.
@immutable
final class PaginationInfo {
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

  const PaginationInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
  });

  /// A factory constructor for creating a new [PaginationInfo] instance from a JSON map.
  ///
  /// It performs robust parsing with safe defaults to prevent runtime errors
  /// in case of a malformed or incomplete API response.
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      hasMorePages: json['has_more_pages'] as bool? ?? false,
    );
  }

  /// A factory for creating a default, empty pagination state.
  /// Useful for initializing state or for offline responses.
  /// A factory for creating a default, initial pagination state.
  ///
  /// This provides a convenient way to represent the state before the first
  /// API call has been made.
  factory PaginationInfo.initial() {
    return const PaginationInfo(
      total: 0,
      perPage: 0,
      currentPage: 1,
      totalPages: 1,
      // Assume there are more pages until the first fetch proves otherwise.
      hasMorePages: true, 
    );
  }

  // --- Boilerplate code for value equality ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationInfo &&
        other.total == total &&
        other.perPage == perPage &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.hasMorePages == hasMorePages;
  }

  @override
  int get hashCode {
    return total.hashCode ^
        perPage.hashCode ^
        currentPage.hashCode ^
        totalPages.hashCode ^
        hasMorePages.hashCode;
  }
}

