import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';

const double _kSheetTopFadeFraction = 0.05;
const double _kSheetBottomFadeFraction = 0.025;

/// Glass-morphism bottom sheet body used by the settings bottom sheets.
///
/// Renders a [GlassDialogSurface] with top-rounded corners, a glass
/// drag-handle and an optional title. The body is laid out in the same way
/// as the previous surface-coloured sheet, so existing sheet contents keep
/// working unchanged.
class GlassBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double? heightPercentage;
  final bool showHandleBar;

  /// When true, the sheet only uses as much height as the content needs (capped
  /// to ~92% of the screen) and scrolls if necessary. When false, uses
  /// [heightPercentage] or 80% of the screen, as before.
  final bool shrinkToContent;

  const GlassBottomSheet({
    super.key,
    this.title,
    required this.children,
    this.heightPercentage,
    this.showHandleBar = true,
    this.shrinkToContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ScrollBehavior sheetScrollBehavior = _BottomSheetScrollBehavior();
    if (shrinkToContent) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingSm,
          0,
          glassSpacingSm,
          glassSpacingSm,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
          child: ScrollConfiguration(
            behavior: sheetScrollBehavior,
            child: GlassDialogSurface(
              borderRadius: const BorderRadius.all(
                Radius.circular(glassSurfaceRadiusLg + glassSpacingSm / 2),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showHandleBar) _buildDragHandleBar(isDark: isDark),
                    if (title != null && title!.isNotEmpty)
                      _buildTitle(context: context, colorScheme: colorScheme),
                    if (children.isNotEmpty)
                      Flexible(
                        fit: FlexFit.loose,
                        child: ScrollFadeMask(
                          // Sticky header above + subtle dissolve of scrolled
                          // content beneath it.
                          topFadeFraction: _kSheetTopFadeFraction,
                          bottomFadeFraction: _kSheetBottomFadeFraction,
                          child: SingleChildScrollView(
                            child: children.length == 1
                                ? children.first
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: children,
                                  ),
                          ),
                        ),
                      ),
                    const SizedBox(height: glassSpacingMd),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final double heightFactor = heightPercentage ?? 0.8;
    final double height = screenHeight * heightFactor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        glassSpacingSm,
        0,
        glassSpacingSm,
        glassSpacingSm,
      ),
      child: SizedBox(
        height: height,
        child: ScrollConfiguration(
          behavior: sheetScrollBehavior,
          child: GlassDialogSurface(
            borderRadius: const BorderRadius.all(
              Radius.circular(glassSurfaceRadiusLg + glassSpacingSm / 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  if (showHandleBar) _buildDragHandleBar(isDark: isDark),
                  if (title != null && title!.isNotEmpty)
                    _buildTitle(context: context, colorScheme: colorScheme),
                  if (children.isNotEmpty)
                    Expanded(
                      // Only auto-fade single-child sheets (the common case:
                      // a single ListView/GridView/ScrollView). Multi-child
                      // sheets (e.g. filter + list) must apply ScrollFadeMask
                      // themselves on the actual scrollable element to avoid
                      // fading fixed headers at the top.
                      child: children.length == 1
                          ? ScrollFadeMask(
                              topFadeFraction: _kSheetTopFadeFraction,
                              bottomFadeFraction: _kSheetBottomFadeFraction,
                              child: children.first,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: children,
                            ),
                    ),
                  const SizedBox(height: glassSpacingMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandleBar({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(top: glassDragHandleTopGap),
      child: Center(
        child: Container(
          width: glassDragHandleWidth,
          height: glassDragHandleHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: isDark
                  ? glassDragHandleAlphaDark
                  : glassDragHandleAlphaLight,
            ),
            borderRadius: BorderRadius.circular(glassSpacingXs / 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle({
    required BuildContext context,
    required ColorScheme colorScheme,
  }) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingLg,
          glassSpacingLg,
          glassSpacingLg,
          glassSpacingSm,
        ),
        child: Text(
          title!,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _BottomSheetScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
