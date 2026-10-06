import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class ThemeModeBottomsheet {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    // The library's static show() freezes settings outside its content builder.
    // Build the whole native sheet reactively so its handle and footer also
    // follow a theme change while this route stays open.
    await Navigator.of(context).push<void>(
      _ThemeSheetRoute(
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 350),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    ),
                  ),
              child: child,
            ),
        pageBuilder: (dialogContext, animation, secondaryAnimation) => Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(settingsProvider).value;
            final current = state?.themePreference ?? ThemePreference.system;

            final isDark = Theme.of(context).brightness == Brightness.dark;
            return SafeArea(
              top: false,
              left: false,
              right: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _DismissibleThemeSheet(
                  child: AppModalSurfaceScope(
                    child: liquid.GlassSheet(
                      showDragIndicator: isDark,
                      quality: liquid.GlassQuality.standard,
                      settings: appGlassSettings(
                        context,
                        blur: glassSurfaceBlurBottomSheet,
                        tint: isDark
                            ? null
                            : Theme.of(context).colorScheme.surface.withValues(
                                alpha:
                                    1 -
                                    (1 - glassDialogTintAlphaLight) *
                                        (1 - glassDialogContentAlphaLight),
                              ),
                      ),
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isDark)
                              Semantics(
                                label: MaterialLocalizations.of(context)
                                    .modalBarrierDismissLabel,
                                button: true,
                                onTap: () => Navigator.maybePop(context),
                                child: Center(
                                  child: Container(
                                    width: glassDragHandleWidth,
                                    height: glassDragHandleHeight,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                            alpha: glassModalHandleAlphaLight,
                                          ),
                                      borderRadius: BorderRadius.circular(
                                        glassSpacingXs / 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                glassSpacingLg,
                                glassSpacingLg,
                                glassSpacingLg,
                                glassSpacingSm,
                              ),
                              child: Text(
                                l10n.themeMode,
                                style: AppTypography.sheetTitle(
                                  Theme.of(context),
                                ),
                              ),
                            ),
                            SelectionList(
                              items: [
                                SelectionItem(
                                  title: l10n.themeModeLight,
                                  value: ThemePreference.light.name,
                                ),
                                SelectionItem(
                                  title: l10n.themeModeDark,
                                  value: ThemePreference.dark.name,
                                ),
                                SelectionItem(
                                  title: l10n.themeModeSystem,
                                  value: ThemePreference.system.name,
                                ),
                              ],
                              selectedValue: current.name,
                              onItemSelected: (themeName) async {
                                if (themeName != null) {
                                  ThemePreference preference;
                                  switch (themeName) {
                                    case 'light':
                                      preference = ThemePreference.light;
                                      break;
                                    case 'dark':
                                      preference = ThemePreference.dark;
                                      break;
                                    case 'system':
                                      preference = ThemePreference.system;
                                      break;
                                    default:
                                      preference = ThemePreference.system;
                                  }
                                  await ref
                                      .read(settingsProvider.notifier)
                                      .setThemePreference(preference);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The navigator rebuilds the barrier when its theme changes, including while
/// the theme picker is open. Preserve the library's original Dark barrier.
class _ThemeSheetRoute extends RawDialogRoute<void> {
  _ThemeSheetRoute({
    required super.pageBuilder,
    required super.barrierLabel,
    required super.barrierDismissible,
    required super.transitionBuilder,
    required super.transitionDuration,
  });

  @override
  Color get barrierColor =>
      navigator != null &&
          Theme.of(navigator!.context).brightness == Brightness.light
      ? Colors.black.withValues(alpha: glassBarrierAlpha)
      : liquid.GlassDefaults.barrierColor;
}

/// Keeps the native sheet's downward drag dismissal when its settings rebuild.
class _DismissibleThemeSheet extends StatefulWidget {
  const _DismissibleThemeSheet({required this.child});

  final Widget child;

  @override
  State<_DismissibleThemeSheet> createState() => _DismissibleThemeSheetState();
}

class _DismissibleThemeSheetState extends State<_DismissibleThemeSheet> {
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onVerticalDragStart: (_) => setState(() => _isDragging = true),
    onVerticalDragUpdate: (details) => setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        0.0,
        double.infinity,
      );
    }),
    onVerticalDragEnd: (details) {
      final height = (context.findRenderObject() as RenderBox).size.height;
      if (_dragOffset > height * .25 || (details.primaryVelocity ?? 0) > 500) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isDragging = false;
          _dragOffset = 0;
        });
      }
    },
    onVerticalDragCancel: () => setState(() {
      _isDragging = false;
      _dragOffset = 0;
    }),
    child: AnimatedContainer(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _dragOffset, 0),
      child: widget.child,
    ),
  );
}
