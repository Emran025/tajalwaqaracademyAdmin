part of 'tracking_session_bloc.dart';

// The state of the current recitation tracking session.
class TrackingSessionState extends Equatable {
  final String enrollmentId;
  final TrackingType currentTaskType;

  // The key is now the domain TrackingType from your core models,
  // and the value is the domain TrackingDetailEntity.
  final Map<TrackingType, TrackingDetailEntity> taskProgress;

  final DataStatus status;
  final String? errorMessage;

  final List<Mistake> historicalMistakes;
  final DataStatus historicalMistakesStatus;

  const TrackingSessionState({
    required this.enrollmentId,
    this.currentTaskType =
        TrackingType.memorization, // Assuming memorize is the default
    this.taskProgress = const {},
    this.status = DataStatus.initial,
    this.errorMessage,
    this.historicalMistakes = const [], // Initialize as empty map
    this.historicalMistakesStatus = DataStatus.initial,
  });

  // A computed property to get the progress for the current task.
  // It can now be null if no progress exists for the current task type.
  TrackingDetailEntity? get currentTaskDetail => taskProgress[currentTaskType];

  // The copyWith method remains here as it's for the State object.

  TrackingSessionState copyWith({
    String? enrollmentId,
    TrackingType? currentTaskType,
    Map<TrackingType, TrackingDetailEntity>? taskProgress,
    DataStatus? status,
    String? errorMessage,
    List<Mistake>? historicalMistakes,
    DataStatus? historicalMistakesStatus,
  }) {
    return TrackingSessionState(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      currentTaskType: currentTaskType ?? this.currentTaskType,
      taskProgress: taskProgress ?? this.taskProgress,
      status: status ?? this.status,
      errorMessage: errorMessage,
      historicalMistakes: historicalMistakes ?? this.historicalMistakes,
      historicalMistakesStatus:
          historicalMistakesStatus ?? this.historicalMistakesStatus,
    );
  }

  @override
  List<Object?> get props => [
    enrollmentId,
    currentTaskType,
    taskProgress,
    status,
    errorMessage,
    historicalMistakes,
    historicalMistakesStatus,
  ];
}
