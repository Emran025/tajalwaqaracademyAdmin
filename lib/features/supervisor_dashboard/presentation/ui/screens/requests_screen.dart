import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../../../../../core/entities/list_item_entity.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../shared/widgets/caerd_tile.dart';

import '../../../../../shared/widgets/avatar.dart';
import '../../../../StudentsManagement/presentation/ui/screens/student_profile_screen.dart';
import '../../bloc/supervisor_bloc.dart';

class RequestsScreen extends StatefulWidget {
  final UserRole entityType;
  const RequestsScreen({super.key, required this.entityType});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late final SupervisorBloc _supervisorBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _supervisorBloc = context.read<SupervisorBloc>();
    _supervisorBloc.add(
      ApplicantsFetched(page: 1, entityType: widget.entityType),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _supervisorBloc.add(MoreApplicantsLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BlocBuilder<SupervisorBloc, SupervisorState>(
                  builder: (context, state) {
                    if (state is SupervisorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SupervisorError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${state.message}'),
                            ElevatedButton(
                              onPressed: () {
                                _supervisorBloc.add(
                                  ApplicantsFetched(
                                    page: 1,
                                    entityType: widget.entityType,
                                  ),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is SupervisorLoaded) {
                      if (state.applicants.isEmpty) {
                        //   return const Center(child: CircularProgressIndicator());
                      }
                      final applicants = state.applicants;

                      return ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            applicants.length +
                            (state.isLoadingMoreApplicants ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (ctx, i) {
                          if (i == applicants.length) {
                            // عرض مؤشر التحميل في النهاية
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return _buildStudentCard(applicants[i].user);
                        },
                      );
                    }
                    return Center();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(ListItemEntity student) {
    return CustomListTile(
      title: student.name,
      moreIcon: Icons.more_vert,
      leading: Avatar(gender: student.gender, pic: student.avatar),
      subtitle: "${student.country} - ${student.city}",
      backgroundColor: AppColors.accent12,
      hasMoreIcon: false,
      tajLable: student.status.labelAr,
      border: Border.all(color: AppColors.accent70, width: 0.5),
      onMoreTab: () => {},
      onListTilePressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(studentID: student.id),
          ),
        );
      },
      onTajPressed: () {},
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
