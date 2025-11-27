import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_status.dart'; // The unified enum
import '../bloc/quran_reader_bloc.dart';
import '../bloc/tracking_session_bloc.dart';
import '../widgets/recitation_mode_sidebar.dart';
import '../widgets/page_display_widget.dart';
import '../widgets/session_bottom_toolbar.dart';
import '../widgets/session_top_toolbar.dart';

class QuranReaderScreen extends StatefulWidget {
  final String enrollmentId; // Type is now String

  const QuranReaderScreen({super.key, required this.enrollmentId});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ValueNotifier<bool> _areToolbarsVisible = ValueNotifier(true);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 2. Manage PageController's lifecycle correctly
  late final PageController _pageController;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    log("------------------${widget.enrollmentId}");

    // 3. Request initial data for Quran Reader
    context.read<QuranReaderBloc>().add(SurahsListRequested());

    // The TrackingSessionBloc is already started via the BlocProvider in navigation code.
    // _requestPageData();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _areToolbarsVisible.value = false;
    });
  }

  @override
  void dispose() {
    _areToolbarsVisible.dispose();
    _pageController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _toggleToolbarsVisibility() {
    _areToolbarsVisible.value = !_areToolbarsVisible.value;
  }

  void _toggleSidebarsVisibility() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // 4. Create a helper method for pre-fetching page data
  void _requestPageData(int pageIndex) {
    currentPageIndex = pageIndex;
    // context.read<QuranReaderBloc>().add(SurahsListRequested());
    final quranBloc = context.read<QuranReaderBloc>();
    quranBloc.add(PageDataRequested(pageIndex + 1));
    if (pageIndex > 0) {
      quranBloc.add(PageDataRequested(pageIndex));
    }
    if (pageIndex < 603) {
      quranBloc.add(PageDataRequested(pageIndex + 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MultiBlocListener(
        listeners: [
          BlocListener<TrackingSessionBloc, TrackingSessionState>(
            listenWhen: (previous, current) =>
                previous.status != DataStatus.success &&
                current.status == DataStatus.success &&
                !(current.currentTaskDetail != null &&
                    previous.currentTaskDetail != null &&
                    current.currentTaskDetail?.trackingTypeId ==
                        previous.currentTaskDetail?.trackingTypeId),
            // && current.currentTaskDetail != previous.currentTaskDetail,
            listener: (context, state) {
              // Get the starting page for the current task
              final lastPage =
                  (((state.currentTaskDetail?.toTrackingUnitId.fromPage ?? 1) -
                      1) +
                  (state.currentTaskDetail?.gap.floor() ?? 0));
              // Jump to the last read page if the controller is ready
              _requestPageData(lastPage - 1);
              if (_pageController.hasClients) {
                _pageController.jumpToPage(
                  lastPage - 1,
                ); // PageView is 0-indexed
              }
            },
          ),
        ],
        // 6. Use PopScope to control back navigation
        child: PopScope(
          canPop: false,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: RecitationSideBar(),
            body: Row(
              children: [
                Expanded(
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: _toggleToolbarsVisibility,
                      child: Stack(
                        children: [
                          _buildPageView(),
                          ValueListenableBuilder<bool>(
                            valueListenable: _areToolbarsVisible,
                            builder: (context, isVisible, child) {
                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: isVisible ? 0 : -100,
                                left: 0,
                                right: 0,
                                child: child!,
                              );
                            },
                            child: SessionTopToolbar(
                              onTap: _toggleSidebarsVisibility,
                              enrollmentId: widget.enrollmentId,
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _areToolbarsVisible,
                            builder: (context, isVisible, child) {
                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                bottom: isVisible ? 0 : -100,
                                left: 0,
                                right: 0,
                                child: child!,
                              );
                            },
                            child: SessionBottomToolbar(
                              jumpToPage: (index) {
                                setState(() {
                                  _requestPageData(index);
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(
                                      index,
                                    ); // PageView is 0-indexed
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    // 7. The PageView now uses the state-managed _pageController
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        itemCount: 604,
        controller: _pageController,
        onPageChanged: (pageIndex) {
          _requestPageData(pageIndex);
        },
        itemBuilder: (_, index) {
          return PageDisplayWidget(pageNumber: index + 1);
        },
      ),
    );
  }
}
