import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';

/// Glass-morphism card surface used across the settings screen and its
/// sub-screens.
///
/// Provides a translucent tinted background with a subtle white border. When
/// [isActive] is true the card uses a primary tint and border. Grouped rows
/// preserve state decoration without adding another glass surface.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isActive;
  final bool enabled;

  /// The opening sheet provides feedback; avoid an ink animation underneath it.
  final bool modalTrigger;
  final VoidCallback? onTap;
  final Color? tintColor;
  final double? tintAlpha;
  final Color? borderColor;
  final double? borderAlpha;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = glassSurfaceRadiusMd,
    this.isActive = false,
    this.enabled = true,
    this.modalTrigger = false,
    this.onTap,
    this.tintColor,
    this.tintAlpha,
    this.borderColor,
    this.borderAlpha,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool lightModal = AppModalSurfaceScope.isLight(context);
    final double enabledMul = enabled ? 1.0 : glassCardDisabledMultiplier;

    final Color baseBackground =
        (lightModal ? colorScheme.onSurface : Colors.white).withValues(
          alpha:
              (lightModal
                  ? glassModalFillAlphaLight
                  : isDark
                  ? glassTintAlphaDark * glassCardBaseTintAlphaDarkMultiplier
                  : glassTintAlphaLight) *
              enabledMul,
        );
    final Color activeBackground = colorScheme.primary.withValues(
      alpha:
          (isDark
              ? glassCardActiveTintAlphaDark
              : glassCardActiveTintAlphaLight) *
          enabledMul,
    );
    final Color tintedBackground = tintColor != null
        ? Color.alphaBlend(
            tintColor!.withValues(alpha: (tintAlpha ?? 0.0) * enabledMul),
            baseBackground,
          )
        : baseBackground;
    final Color baseBorder = (lightModal ? colorScheme.onSurface : Colors.white)
        .withValues(
          alpha:
              (lightModal
                  ? glassModalBorderAlphaLight
                  : isDark
                  ? glassBorderAlphaDark *
                        glassCardBaseBorderAlphaDarkMultiplier
                  : glassBorderAlphaLight) *
              enabledMul,
        );
    final Color activeBorder = colorScheme.primary.withValues(
      alpha: glassCardActiveBorderAlpha * enabledMul,
    );
    final Color roleBorder = borderColor != null
        ? borderColor!.withValues(alpha: (borderAlpha ?? 1.0) * enabledMul)
        : baseBorder;

    final bool grouped =
        context.dependOnInheritedWidgetOfExactType<_GlassCardGroupScope>() !=
        null;
    final Widget card = grouped
        ? DecoratedBox(
            // The group already supplies the base tint and outer outline.
            // Only paint row-specific emphasis; never add another glass layer.
            decoration: BoxDecoration(
              color: isActive
                  ? activeBackground
                  : tintColor?.withValues(
                      alpha: (tintAlpha ?? 0.0) * enabledMul,
                    ),
              border: isActive || borderColor != null
                  ? Border.all(
                      color: isActive ? activeBorder : roleBorder,
                      width: isActive
                          ? glassCardActiveBorderWidth
                          : borderWidth,
                    )
                  : null,
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          )
        : AppGlassSurface(
            refractive: false,
            padding: padding,
            borderRadius: borderRadius,
            tint: isActive ? activeBackground : tintedBackground,
            borderColor: isActive ? activeBorder : roleBorder,
            borderWidth: isActive ? glassCardActiveBorderWidth : borderWidth,
            child: child,
          );

    final EdgeInsetsGeometry effectiveMargin = grouped
        ? EdgeInsets.zero
        : (margin ?? EdgeInsets.zero);

    if (onTap == null) {
      return Padding(padding: effectiveMargin, child: card);
    }

    return Padding(
      padding: effectiveMargin,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: grouped
              ? BorderRadius.zero
              : BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          splashFactory: modalTrigger ? NoSplash.splashFactory : null,
          splashColor: modalTrigger ? Colors.transparent : null,
          highlightColor: modalTrigger ? Colors.transparent : null,
          borderRadius: grouped
              ? BorderRadius.zero
              : BorderRadius.circular(borderRadius),
          child: card,
        ),
      ),
    );
  }
}

/// A single material for related settings rows; each row keeps its own action.
class GlassCardGroup extends StatelessWidget {
  const GlassCardGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: _GlassCardGroupScope(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: 0.35),
              ),
            children[i],
          ],
        ],
      ),
    ),
  );
}

class _GlassCardGroupScope extends InheritedWidget {
  const _GlassCardGroupScope({required super.child});
  @override
  bool updateShouldNotify(_GlassCardGroupScope oldWidget) => false;
}
