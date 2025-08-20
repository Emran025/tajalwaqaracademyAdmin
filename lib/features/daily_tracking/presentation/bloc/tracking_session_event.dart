part of 'tracking_session_bloc.dart';

abstract class TrackingSessionEvent extends Equatable {
  const TrackingSessionEvent();
  @override
  List<Object> get props => [];
}

// --- Session Lifecycle Events ---

/// Dispatched when the screen is first loaded to fetch or create initial session data.
class SessionStarted extends TrackingSessionEvent {
  final String enrollmentId;
  const SessionStarted({required this.enrollmentId});
  @override
  List<Object> get props => [enrollmentId];
}

/// Dispatched when the user taps on an icon in the side navigation bar (Memorize, Review, etc.).
class TaskTypeChanged extends TrackingSessionEvent {
  final TrackingType newType;
  const TaskTypeChanged({required this.newType});
  @override
  List<Object> get props => [newType];
}

// --- Mistake Interaction Events ---

/// Dispatched when the user taps on a word in the Quran text to mark/unmark a mistake.
class WordTappedForMistake extends TrackingSessionEvent {
  final int ayahId;
  final int wordIndex;
    final MistakeType newMistakeType;

  const WordTappedForMistake({required this.ayahId, required this.wordIndex ,required this.newMistakeType,});
  @override
  List<Object> get props => [ayahId, wordIndex,newMistakeType];
}

/// Dispatched from the Task Report Dialog when a teacher categorizes a mistake.
class MistakeCategorized extends TrackingSessionEvent {
  final String mistakeId; // The unique ID of the mistake to be updated.
  final MistakeType newMistakeType;
  const MistakeCategorized({
    required this.mistakeId,
    required this.newMistakeType,
  });
  @override
  List<Object> get props => [mistakeId, newMistakeType];
}

// --- Task Progress Update Events (from TaskReportDialog) ---

/// (**NEW**) Dispatched when the teacher changes the quality rating (1-5 stars).
class QualityRatingChanged extends TrackingSessionEvent {
  final int newRating;
  const QualityRatingChanged({required this.newRating});
  @override
  List<Object> get props => [newRating];
}

/// (**NEW**) Dispatched when the teacher types in the task-specific notes field.
/// This could be used for auto-saving, but for now, we'll use a final save event.
class TaskNotesChanged extends TrackingSessionEvent {
  final String newNotes;
  const TaskNotesChanged({required this.newNotes});
  @override
  List<Object> get props => [newNotes];
}

/// (**NEW**) Dispatched when the "Save Report" button is pressed in the TaskReportDialog.
/// This event will trigger the saving of mistakes, rating, and notes for the CURRENT task.
class TaskReportSaved extends TrackingSessionEvent {
  // We can pass the final notes and rating here if we don't save them on change.
  final String notes;
  final int rating;
  final bool isFinalizingTask;

  const TaskReportSaved({
    required this.notes,
    required this.rating,
    required this.isFinalizingTask,
  });
  @override
  List<Object> get props => [notes, rating, isFinalizingTask];
}

/// Dispatched when the "Final Report" button is pressed in the side bar,
/// to save the final behavioral and general notes for the WHOLE session.
class FinalSessionReportSaved extends TrackingSessionEvent {
  final String behavioralNotes;
  final String generalNotes;
  const FinalSessionReportSaved({
    required this.behavioralNotes,
    required this.generalNotes,
  });
  @override
  List<Object> get props => [behavioralNotes, generalNotes];
}

/// Dispatched when the user taps the end-of-ayah symbol to mark the recitation range.
class RecitationRangeEnded extends TrackingSessionEvent {
  final int pageNumber;
  final int ayah;
  const RecitationRangeEnded({required this.pageNumber, required this.ayah});
  @override
  List<Object> get props => [pageNumber, ayah];
}

// lib/features/daily_tracking/presentation/bloc/tracking_session_event.dart

// NEW: Event to fetch the historical mistakes for a specific type.
class HistoricalMistakesRequested extends TrackingSessionEvent {
    final int? fromPage;
  final int? toPage;

  const HistoricalMistakesRequested({ this.fromPage , this.toPage});

  @override
  List<Object> get props => [fromPage ??0 , toPage ?? 0];
}