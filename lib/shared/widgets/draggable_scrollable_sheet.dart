import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_theme.dart';

class DraggaBottomSheetBUtton<B extends BlocBase<S>, S> extends StatefulWidget {
  final Widget child;
  final void Function()? onTap;
  final B bloc;
  final List<Widget> Function(S state) contentBuilder;

  const DraggaBottomSheetBUtton({
    super.key,
    required this.onTap,
    required this.child,
    required this.bloc,
    required this.contentBuilder,
  });

  @override
  State<DraggaBottomSheetBUtton<B, S>> createState() =>
      _DraggaBottomSheetBUttonState<B, S>();
}

class _DraggaBottomSheetBUttonState<B extends BlocBase<S>, S>
    extends State<DraggaBottomSheetBUtton<B, S>> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _openDetail(context);
              widget.onTap!();
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) {
        return BlocProvider<B>.value(
          value: widget.bloc,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightCream26),
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.mediumDark70,
                        AppColors.darkBackground70,
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Drag handle
                        Container(
                          width: 75,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.lightCream70,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Content from builder
                        BlocBuilder<B, S>(
                          builder: (context, state) {
                            return Column(
                              children: widget.contentBuilder(state),
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  "اغلاق",
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
