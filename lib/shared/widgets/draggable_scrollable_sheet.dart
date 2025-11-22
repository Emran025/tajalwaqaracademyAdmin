import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_theme.dart';

class DraggaBottomSheetBUtton extends StatefulWidget {
  final List<Widget> children;
  final Widget child;
  final void Function()? onTap;
  const DraggaBottomSheetBUtton({
    super.key,
    required this.onTap,
    required this.children,
    required this.child,
  });

  @override
  State<DraggaBottomSheetBUtton> createState() =>
      _DraggaBottomSheetBUttonState();
}

class _DraggaBottomSheetBUttonState extends State<DraggaBottomSheetBUtton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _openDetail();
              widget.onTap!();
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _openDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

                      // Header with icon
                      ...widget.children.map(
                        (element) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: element,
                        ),
                      ),

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
        );
      },
    );
  }
}
