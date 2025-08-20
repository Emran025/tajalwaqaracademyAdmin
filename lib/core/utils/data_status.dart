///lib/core/utils/data_status.dart
/// Represents the status of data operations in the application.
/// This enum is used to indicate the current state of data fetching,
/// processing, or any other data-related operation.
enum DataStatus {
  initial, // Initial state before any operation starts
  loading, // Data is currently being loaded
  success, // Data has been successfully loaded or processed
  failure, // An error occurred during the data operation
}