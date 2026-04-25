// Base glass design tokens shared across reusable widgets.

// Radius
const double glassSurfaceRadiusSm = 16;
const double glassSurfaceRadiusMd = 18;
const double glassSurfaceRadiusLg = 24;
const double glassSurfaceRadiusXl = 32;
const double glassSurfaceRadiusPill = 999;

// Blur
const double glassSurfaceBlurDefault = 20;
const double glassSurfaceBlurDialog = 28;
const double glassSurfaceBlurSubtle = 18;

// Alpha (tint + border)
const double glassTintAlphaLight = 0.28;
const double glassTintAlphaDark = 0.08;
const double glassBorderAlphaLight = 0.45;
const double glassBorderAlphaDark = 0.18;
const double glassBarrierAlpha = 0.35;

// Alpha (active/emphasis variants)
const double glassTintAlphaActiveLight = 0.22;
const double glassTintAlphaActiveDark = 0.35;
const double glassBorderAlphaActive = 0.55;

// Shadow
const double glassShadowBlurSm = 16;
const double glassShadowBlurMd = 18;
const double glassShadowBlurLg = 32;
const double glassShadowOffsetYSm = 6;
const double glassShadowOffsetYMd = 16;
const double glassShadowAlphaLight = 0.18;
const double glassShadowAlphaDark = 0.35;
const double glassShadowAlphaDialogLight = 0.22;
const double glassShadowAlphaDialogDark = 0.5;
const double glassShadowAlphaActiveLight = 0.30;
const double glassShadowAlphaActiveDark = 0.32;

// Spacing
const double glassSpacingXs = 4;
const double glassSpacingSm = 8;
const double glassSpacingMd = 12;
const double glassSpacingLg = 16;
const double glassSpacingXl = 24;
const double glassSpacingXxl = 32;

// Dialog surface tints / borders (used by GlassDialogSurface)
const double glassDialogTintAlphaLight = 0.38;
const double glassDialogTintAlphaDark = 0.5;
const double glassDialogOuterBorderAlphaLight = 0.5;
const double glassDialogOuterBorderAlphaDark = 0.14;
const double glassDialogInnerBorderAlphaLight = 0.28;
const double glassDialogInnerBorderAlphaDark = 0.06;

// Soft divider (used by SoftGradientDivider)
const double glassDividerAlphaLight = 0.28;
const double glassDividerAlphaDark = 0.12;

// Drag handle (used by GlassBottomSheet handle bar and similar)
const double glassDragHandleWidth = 44;
const double glassDragHandleHeight = 4;
const double glassDragHandleTopGap = 10;
const double glassDragHandleAlphaLight = 0.55;
const double glassDragHandleAlphaDark = 0.35;

// Icon badge (used by GlassIconBadge)
const double glassIconBadgeShadowBlur = 8;
const double glassIconBadgeShadowOffsetY = 3;
const double glassIconBadgeShadowAlphaLight = 0.25;
const double glassIconBadgeShadowAlphaDark = 0.35;
const double glassIconBadgeBorderAlphaLight = 0.35;
const double glassIconBadgeBorderAlphaDark = 0.20;
const double glassIconBadgeGradientTopAlphaLight = 0.95;
const double glassIconBadgeGradientTopAlphaDark = 0.85;
const double glassIconBadgeGradientBottomAlphaLight = 0.70;
const double glassIconBadgeGradientBottomAlphaDark = 0.55;

// Glass card active tint (used by GlassCard)
const double glassCardActiveTintAlphaLight = 0.18;
const double glassCardActiveTintAlphaDark = 0.22;
const double glassCardActiveBorderAlpha = 0.85;
const double glassCardActiveBorderWidth = 1.5;
const double glassCardBaseTintAlphaDarkMultiplier = 0.75;
const double glassCardBaseBorderAlphaDarkMultiplier = 0.78;
const double glassCardDisabledMultiplier = 0.55;

// Subtle glass surface (used by GlassContainer default)
// Aligned with glassTintAlphaLight to keep enough surface presence on the
// brighter Light Mode backdrop while staying subdued in Dark Mode.
const double glassSurfaceSubtleTintAlphaLight = 0.28;
const double glassSurfaceSubtleTintAlphaDark = 0.30;
const double glassSurfaceSubtleBorderAlphaLight = 0.25;
const double glassSurfaceSubtleBorderAlphaDark = 0.15;

// Multiplier applied to the subtle border alpha when rendering a primary-tinted
// edge in Light Mode. Lower than 1.0 keeps the edge subtle so glass surfaces
// don't read as flat coloured cards.
const double glassSurfaceSubtleBorderPrimaryFactorLight = 0.72;

// Backdrop / aurora ambient blobs (used by CalendarBackdrop)
const double glassBackdropGradientTopAlphaLight = 0.14;
const double glassBackdropGradientTopAlphaDark = 0.14;
const double glassBackdropBlobLargeAlphaLight = 0.42;
const double glassBackdropBlobLargeAlphaDark = 0.42;
const double glassBackdropBlobMediumAlphaLight = 0.30;
const double glassBackdropBlobMediumAlphaDark = 0.28;
const double glassBackdropBlobSoftAlphaLight = 0.18;
const double glassBackdropBlobSoftAlphaDark = 0.16;

// Multi-accent blobs in the aurora backdrop (Light Mode kept richer to give
// the BackdropFilter something to mix with).
//
// Source colors are read live from `partnerProvider` (sole writer for
// `setMyAccentColor` / `setPartnerAccentColor`):
// - `glassBackdropBlobAccentAlpha*` colors the blob driven by
//   `myAccentColorValue` (primary duty group accent).
// - `glassBackdropBlobWarmAlpha*` colors the blob driven by
//   `partnerAccentColorValue` (partner duty group accent).
// Both fall back to `colorScheme.primary` while settings load or when null.
const double glassBackdropBlobAccentAlphaLight = 0.22;
const double glassBackdropBlobAccentAlphaDark = 0.30;
const double glassBackdropBlobWarmAlphaLight = 0.14;
const double glassBackdropBlobWarmAlphaDark = 0.20;
