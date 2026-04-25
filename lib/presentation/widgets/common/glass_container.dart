import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/ambient_blob.dart';

/// Reusable glass-morphism container using [BackdropFilter] with a blurred,
/// semi-transparent tint derived from the current color scheme.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = glassSurfaceRadiusLg,
    this.blurSigma = glassSurfaceBlurDefault,
    this.tintOpacity = glassSurfaceSubtleTintAlphaLight,
    this.borderOpacity = glassSurfaceSubtleBorderAlphaLight,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Dark mode receives a slightly stronger tint and softer border to keep the
    // surface readable on dark backdrops. The +0.08 / *0.6 ratios are kept to
    // preserve the historical look while sourcing the base values from tokens.
    final Color tintColor = isDark
        ? colorScheme.primary.withValues(alpha: tintOpacity + 0.08)
        : colorScheme.primary.withValues(alpha: tintOpacity);
    // Light Mode: a faintly primary-tinted edge reads better on the bright
    // aurora than a pure white border that would otherwise vanish.
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity * 0.6)
        : colorScheme.primary.withValues(
            alpha: borderOpacity * glassSurfaceSubtleBorderPrimaryFactorLight,
          );

    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? glassShadowAlphaDark : glassShadowAlphaLight,
                ),
                blurRadius: glassShadowBlurMd,
                offset: const Offset(0, glassShadowOffsetYSm),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin == null) {
      return content;
    }
    return Padding(padding: margin!, child: content);
  }
}

/// Ambient "aurora" background used beneath the glass layers so the blur is
/// actually visible over the scaffold.
///
/// Renders a top-to-bottom tinted gradient as base layer and five statically
/// positioned blobs on top. Three blobs follow the theme primary, the
/// remaining two are driven by the user's accent color settings:
/// - one blob uses `myAccentColorValue` (the primary duty group accent),
/// - one blob uses `partnerAccentColorValue` (the partner duty group accent).
/// Both fall back to `colorScheme.primary` while settings load or when null.
class CalendarBackdrop extends ConsumerWidget {
  final Widget child;

  const CalendarBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Accent values live on `partnerProvider` because `PartnerNotifier` is the
    // sole writer for `setMyAccentColor` / `setPartnerAccentColor`. Watching
    // `settingsProvider` here would miss live updates because it is only
    // refreshed on cold load. See `partner_notifier.dart`.
    final int? myAccentValue = ref.watch(
      partnerProvider.select(
        (AsyncValue<PartnerUiState> s) => s.value?.myAccentColorValue,
      ),
    );
    final int? partnerAccentValue = ref.watch(
      partnerProvider.select(
        (AsyncValue<PartnerUiState> s) => s.value?.partnerAccentColorValue,
      ),
    );
    final Color myAccent = myAccentValue != null
        ? Color(myAccentValue)
        : colorScheme.primary;
    final Color partnerAccent = partnerAccentValue != null
        ? Color(partnerAccentValue)
        : colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            Color.alphaBlend(
              colorScheme.primary.withValues(
                alpha: isDark
                    ? glassBackdropGradientTopAlphaDark
                    : glassBackdropGradientTopAlphaLight,
              ),
              colorScheme.surface,
            ),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final Color primary = colorScheme.primary;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -80,
                right: -100,
                child: AmbientBlob(
                  color: primary.withValues(
                    alpha: isDark
                        ? glassBackdropBlobLargeAlphaDark
                        : glassBackdropBlobLargeAlphaLight,
                  ),
                  diameter: 320,
                ),
              ),
              Positioned(
                top: 120,
                left: -60,
                child: AmbientBlob(
                  color: myAccent.withValues(
                    alpha: isDark
                        ? glassBackdropBlobAccentAlphaDark
                        : glassBackdropBlobAccentAlphaLight,
                  ),
                  diameter: 240,
                ),
              ),
              Positioned(
                bottom: 40,
                left: -120,
                child: AmbientBlob(
                  color: primary.withValues(
                    alpha: isDark
                        ? glassBackdropBlobMediumAlphaDark
                        : glassBackdropBlobMediumAlphaLight,
                  ),
                  diameter: 280,
                ),
              ),
              Positioned(
                bottom: -60,
                right: -60,
                child: AmbientBlob(
                  color: partnerAccent.withValues(
                    alpha: isDark
                        ? glassBackdropBlobWarmAlphaDark
                        : glassBackdropBlobWarmAlphaLight,
                  ),
                  diameter: 200,
                ),
              ),
              Positioned(
                top: height * 0.42,
                left: width * 0.35,
                child: AmbientBlob(
                  color: primary.withValues(
                    alpha: isDark
                        ? glassBackdropBlobSoftAlphaDark
                        : glassBackdropBlobSoftAlphaLight,
                  ),
                  diameter: 420,
                ),
              ),
              child,
            ],
          );
        },
      ),
    );
  }
}
