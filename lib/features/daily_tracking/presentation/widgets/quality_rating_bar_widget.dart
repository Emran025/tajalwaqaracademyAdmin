import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tracking_session_bloc.dart';

/// An interactive star rating bar.
///
/// This widget is driven by the current `score` from the [TrackingSessionBloc]
/// and dispatches [QualityRatingChanged] events when the user selects a new rating.
class QualityRatingBar extends StatelessWidget {
  const QualityRatingBar({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocSelector is highly efficient here. It will only rebuild the stars
    // when the `score` of the current task detail changes.
    return BlocSelector<TrackingSessionBloc, TrackingSessionState, int>(
      selector: (state) => state.currentTaskDetail?.score ?? 0,
      builder: (context, currentRating) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            return IconButton(
              onPressed: () {
                context.read<TrackingSessionBloc>().add(
                  QualityRatingChanged(newRating: starNumber),
                );
              },
              icon: Icon(
                starNumber <= currentRating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        );
      },
    );
  }
}
