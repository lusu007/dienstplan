import 'dart:async';
import 'dart:developer' as dev;

import 'package:dienstplan/presentation/widgets/common/glass_sheet_backdrop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'glass_sheet_backdrop.dart'
    show AppGlassSheetHost, AppGlassSheetBackdrop;

/// Uses prepared glass throughout the native slide transition. When no valid
/// snapshot is available, opens immediately with the normal live material.
Future<T?> showAppGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  Color? barrierColor,
  Clip? clipBehavior,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  final navigator = Navigator.of(context);
  final session = AppGlassSheetHost.begin(context);
  final route = _GlassBottomSheetRoute<T>(
    session: session,
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    modalBarrierColor:
        barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
    barrierLabel: MaterialLocalizations.of(context).scrimLabel,
    barrierOnTapHint: MaterialLocalizations.of(context)
        .scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
    clipBehavior: clipBehavior,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => session == null
        ? builder(context)
        : GlassSheetScope(session: session, child: builder(context)),
  );
  if (kProfileMode) {
    dev.Timeline.instantSync(
      'GlassSheet.open',
      arguments: {'snapshot': session?.hasSnapshot ?? false},
    );
  }
  try {
    final result = await navigator.push<T>(route);
    await route.completed;
    return result;
  } finally {
    // Route overlay render objects have detached before their GPU handles go.
    session?.finish();
  }
}

class _GlassBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _GlassBottomSheetRoute({
    required this.session,
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.backgroundColor,
    super.modalBarrierColor,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.clipBehavior,
    super.isDismissible,
    super.enableDrag,
  });
  final GlassSheetSession? session;
  OverlayEntry? _frozen;
  _LastFrameAnimation? _lastFrame;

  @override
  Animation<double> createAnimation() => _lastFrame = _LastFrameAnimation(
    super.createAnimation(),
    () => session?.hasSnapshot ?? false,
  );

  @override
  bool get finishedWhenPopped =>
      session?.hasSnapshot == true ? false : super.finishedWhenPopped;

  @override
  bool didPop(T? result) {
    _lastFrame?.beginClose();
    final popped = super.didPop(result);
    // Covers a drag or immediate pop which already reached value zero.
    if (popped && controller!.isDismissed && session?.hasSnapshot == true) {
      _lastFrame!.notifyStatusListeners(AnimationStatus.dismissed);
    }
    return popped;
  }

  void _snapshotChanged() {
    _frozen?.opaque = session?.hasSnapshot ?? false;
    _frozen?.markNeedsBuild();
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    final native = super.createOverlayEntries().toList();
    yield native.first;
    if (session?.hasSnapshot == true) {
      session!.addListener(_snapshotChanged);
      _frozen = OverlayEntry(
        opaque: true,
        builder: (_) {
          if (!session!.hasSnapshot) return const SizedBox.shrink();
          return Positioned.fill(
            child: AnimatedBuilder(
              animation: animation!,
              child: RawImage(
                image: session!.snapshot!.original,
                fit: BoxFit.fill,
              ),
              builder: (_, child) => Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  ColoredBox(
                    color: barrierColor.withValues(
                      alpha:
                          barrierColor.a *
                          barrierCurve.transform(animation!.value),
                    ),
                  ),
                  ModalBarrier(
                    color: Colors.transparent,
                    dismissible: isDismissible,
                    onDismiss: () {
                      if (isCurrent) navigator?.maybePop();
                    },
                    semanticsLabel: barrierLabel,
                    semanticsOnTapHint: barrierOnTapHint,
                  ),
                ],
              ),
            ),
          );
        },
      );
      // TransitionRoute mutates opacity of entry zero. The frozen scene must
      // be a separate opaque entry or live filters keep rendering underneath.
      yield _frozen!;
    }
    yield* native.skip(1);
  }

  @override
  void dispose() {
    session?.removeListener(_snapshotChanged);
    _lastFrame?.detach();
    super.dispose();
  }
}

/// Allows a fully off-screen frame to paint before restoring live filters.
/// Only the final status notification is held; values and the slide timing
/// stay native, including drag dismissal.
class _LastFrameAnimation extends ProxyAnimation {
  _LastFrameAnimation(super.parent, this.shouldDefer);
  final bool Function() shouldDefer;
  bool _closing = false;
  bool _holding = false;
  bool _released = false;
  bool _detached = false;
  void beginClose() => _closing = true;
  @override
  AnimationStatus get status =>
      _holding ? AnimationStatus.reverse : super.status;
  @override
  void notifyStatusListeners(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        _closing &&
        !_released &&
        shouldDefer()) {
      if (!_holding) {
        _holding = true;
        unawaited(_releaseAfterPaint());
      }
      return;
    }
    super.notifyStatusListeners(status);
  }

  Future<void> _releaseAfterPaint() async {
    if (kProfileMode) dev.Timeline.instantSync('GlassSheet.offscreen');
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (_detached) return;
    _holding = false;
    _released = true;
    if (kProfileMode) dev.Timeline.instantSync('GlassSheet.liveRestore');
    super.notifyStatusListeners(AnimationStatus.dismissed);
  }

  void detach() {
    _detached = true;
    parent = null;
  }
}
