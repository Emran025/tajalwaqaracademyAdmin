import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import '../../../../../config/di/injection.dart';
import '../../../../../shared/widgets/avatar.dart';
import '../../../../../shared/widgets/taj.dart';
import '../../../../daily_tracking/presentation/bloc/quran_reader_bloc.dart';
import '../../../../daily_tracking/presentation/bloc/tracking_session_bloc.dart';
import '../../../../daily_tracking/presentation/pages/quran_reader_screen.dart';
import '../../../domain/entities/halqa_entity.dart';

class AddTrakingSession extends StatefulWidget {
  final AssignedHalaqasEntity assignedHalaqasEntity;
  final VoidCallback onTap;

  const AddTrakingSession({
    super.key,
    required this.assignedHalaqasEntity,
    required this.onTap,
  });

  @override
  State<AddTrakingSession> createState() => _AddTrakingSessionState();
}

class _AddTrakingSessionState extends State<AddTrakingSession> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.accent12
            : AppColors.mediumDark54,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent70, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "📝 اضافة جلسة متابعة",
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(222, 233, 229, 229),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.accent12
                  : AppColors.mediumDark70,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent70, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              title: Text(
                "المتابعة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              leading: Avatar(size: Size(45, 45)),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  " الموعد القادم للمتابعة : ${formatDate(DateTime.parse(widget.assignedHalaqasEntity.enrolledAt))}",
                  style: TextStyle(fontSize: 9, color: AppColors.lightCream),
                ),
              ),
              onTap: () {
                // In your student list screen, when a student is tapped:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        // Provider for the Quran data (can be a singleton if needed)
                        BlocProvider.value(
                          value:
                              sl<
                                QuranReaderBloc
                              >(), // Assuming it's already created and registered in get_it
                        ),
                        // Provider for the new session
                        BlocProvider(
                          create: (context) =>
                              sl<
                                  TrackingSessionBloc
                                >() // Create a new instance for this session
                                ..add(
                                  SessionStarted(
                                    enrollmentId:
                                        widget
                                            .assignedHalaqasEntity
                                            .enrollmentId ??
                                        widget.assignedHalaqasEntity.id,
                                  ),
                                ), // Start the session!
                        ),
                      ],
                      child: QuranReaderScreen(
                        enrollmentId:
                            widget.assignedHalaqasEntity.enrollmentId ??
                            widget.assignedHalaqasEntity.id,
                      ),
                    ),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onTap();
                      // onPressed!();
                    },
                    child: StatusTag(lable: "تقرير"),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: AppColors.lightCream),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
