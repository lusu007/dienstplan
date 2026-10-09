import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Prepares the last settled app frame for translucent modal sheets.
///
/// Lives above the Navigator so page state survives freezing. Images stay in
/// memory, are invalidated by new frames, and are released on memory pressure
/// or when the app leaves the foreground.
class AppGlassSheetHost extends StatefulWidget {
  const AppGlassSheetHost({super.key, required this.child});
  final Widget child;

  static Future<bool> prepare(BuildContext context) async =>
      await _HostScope.maybeOf(context)?._prepare() ?? false;

  static GlassSheetSession? begin(BuildContext context) =>
      _HostScope.maybeOf(context)?._begin();

  @override
  State<AppGlassSheetHost> createState() => _AppGlassSheetHostState();
}

class _AppGlassSheetHostState extends State<AppGlassSheetHost>
    with WidgetsBindingObserver {
  static const _idleDelay = Duration(milliseconds: 300);
  // Two RGBA images occupy at most ~36 MB before renderer overhead.
  static const _maxPixels = 4500000;
  final _captureKey = GlobalKey();
  final _sessions = <GlassSheetSession>{};
  Timer? _idleTimer;
  Timer? _pressTimer;
  GlassSheetSnapshot? _cached;
  GlassSheetSnapshot? _pressed;
  int? _pointer;
  int _revision = 0;
  int _cacheRevision = -1;
  bool _preparing = false;
  bool _foreground = true;
  (Size, double, EdgeInsets)? _geometry;

  bool get _eligible {
    if (!mounted || !_foreground) return false;
    final media = MediaQuery.of(context);
    return media.viewInsets == EdgeInsets.zero &&
        !media.disableAnimations &&
        !media.accessibleNavigation;
  }

  bool get _ready => _cached != null && _cacheRevision == _revision;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final geometry = (
      media.size,
      View.of(context).devicePixelRatio,
      media.viewInsets,
    );
    if (_geometry != geometry) {
      _geometry = geometry;
      _invalidate(includeSheets: true);
    }
  }

  void _onFrame(Duration _) {
    if (!mounted) return;
    _revision++;
    _schedulePreparation();
    // Registration alone never requests a frame or starts an idle loop.
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _schedulePreparation() {
    _idleTimer?.cancel();
    if (_sessions.isEmpty && _eligible) {
      _idleTimer = Timer(_idleDelay, () {
        unawaited(_prepare());
      });
    }
  }

  Future<bool> _prepare() async {
    if (!_eligible || _sessions.isNotEmpty || _preparing) return false;
    if (_ready) return true;
    _idleTimer?.cancel();
    _preparing = true;
    final revision = _revision;
    final boundary = _captureKey.currentContext?.findRenderObject();
    final viewRatio = View.of(context).devicePixelRatio;
    GlassSheetSnapshot? prepared;
    try {
      if (boundary is! RenderRepaintBoundary || !boundary.hasSize) return false;
      final ratio = math.min(
        viewRatio,
        math.sqrt(_maxPixels / (boundary.size.width * boundary.size.height)),
      );
      prepared = await GlassSheetSnapshot.capture(boundary, ratio);
      if (!mounted ||
          revision != _revision ||
          !_eligible ||
          _sessions.isNotEmpty) {
        prepared.dispose();
        prepared = null;
        return false;
      }
      _cached?.dispose();
      _cached = prepared;
      _cacheRevision = revision;
      return true;
    } catch (_) {
      // A failed capture (e.g. a platform surface) must not prevent opening.
      prepared?.dispose();
      return false;
    } finally {
      _preparing = false;
      if (mounted && _sessions.isEmpty && !_ready && _revision != revision) {
        _schedulePreparation();
      }
    }
  }

  void _clearPress() {
    _pressTimer?.cancel();
    _pressed?.dispose();
    _pressed = null;
    _pointer = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _clearPress();
    if (!_eligible || _sessions.isNotEmpty || !_ready) return;
    // Keep the settled scene before press feedback invalidates the idle cache.
    _pressed = _cached!.clone();
    _pointer = event.pointer;
    _pressTimer = Timer(const Duration(seconds: 2), _clearPress);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_pointer != event.pointer) return;
    _pressTimer?.cancel();
    _pressTimer = Timer(const Duration(milliseconds: 500), _clearPress);
  }

  GlassSheetSession _begin() {
    final image = _eligible && _sessions.isEmpty
        ? (_pressed ?? (_ready ? _cached : null))?.clone()
        : null;
    _clearPress();
    _idleTimer?.cancel();
    final session = GlassSheetSession(image, () {
      if (!mounted) return;
      _sessions.removeWhere((s) => s.isFinished);
      _schedulePreparation();
    });
    _sessions.add(session);
    return session;
  }

  void _invalidate({required bool includeSheets}) {
    _revision++;
    _idleTimer?.cancel();
    _clearPress();
    _cached?.dispose();
    _cached = null;
    if (includeSheets) {
      for (final session in _sessions.toList()) {
        session.invalidate();
      }
    }
  }

  @override
  void didHaveMemoryPressure() => _invalidate(includeSheets: true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      _invalidate(includeSheets: true);
    } else {
      _schedulePreparation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invalidate(includeSheets: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _HostScope(
    state: this,
    child: Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: (event) {
        if (_pointer == event.pointer) _clearPress();
      },
      child: RepaintBoundary(key: _captureKey, child: widget.child),
    ),
  );
}

class _HostScope extends InheritedWidget {
  const _HostScope({required this.state, required super.child});
  final _AppGlassSheetHostState state;
  static _AppGlassSheetHostState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HostScope>()?.state;
  @override
  bool updateShouldNotify(_HostScope oldWidget) => state != oldWidget.state;
}

class GlassSheetSnapshot {
  GlassSheetSnapshot(this.original, this.blurred, this.origin, this.ratio);
  final ui.Image original;
  final ui.Image blurred;
  final Offset origin;
  final double ratio;
  bool _disposed = false;

  static Future<GlassSheetSnapshot> capture(
    RenderRepaintBoundary boundary,
    double ratio,
  ) async {
    final origin = boundary.localToGlobal(Offset.zero);
    final original = await boundary.toImage(pixelRatio: ratio);
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImage(
      original,
      Offset.zero,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: glassSurfaceBlurBottomSheet * ratio,
          sigmaY: glassSurfaceBlurBottomSheet * ratio,
          tileMode: TileMode.clamp,
        ),
    );
    final picture = recorder.endRecording();
    try {
      final blurred = await picture.toImage(original.width, original.height);
      return GlassSheetSnapshot(original, blurred, origin, ratio);
    } catch (_) {
      original.dispose();
      rethrow;
    } finally {
      picture.dispose();
    }
  }

  GlassSheetSnapshot clone() =>
      GlassSheetSnapshot(original.clone(), blurred.clone(), origin, ratio);
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    original.dispose();
    blurred.dispose();
  }
}

class GlassSheetSession extends ChangeNotifier {
  GlassSheetSession(this.snapshot, this.onFinished);
  final GlassSheetSnapshot? snapshot;
  final VoidCallback onFinished;
  bool _valid = true;
  bool isFinished = false;
  bool get hasSnapshot => _valid && snapshot != null && !isFinished;

  void invalidate() {
    if (!_valid || isFinished) return;
    _valid = false;
    notifyListeners();
    // Existing render objects must stop referencing images before release.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      snapshot?.dispose();
    });
  }

  void finish() {
    if (isFinished) return;
    isFinished = true;
    snapshot?.dispose();
    onFinished();
    dispose();
  }
}

class GlassSheetScope extends InheritedNotifier<GlassSheetSession> {
  const GlassSheetScope({
    super.key,
    required GlassSheetSession session,
    required super.child,
  }) : super(notifier: session);
  static GlassSheetSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassSheetScope>()?.notifier;
}

/// Samples the prepared backdrop in screen coordinates while the sheet moves.
class AppGlassSheetBackdrop extends StatefulWidget {
  const AppGlassSheetBackdrop({super.key, required this.child});
  final Widget child;
  static bool isAvailable(BuildContext context) =>
      GlassSheetScope.maybeOf(context)?.hasSnapshot ?? false;
  @override
  State<AppGlassSheetBackdrop> createState() => _AppGlassSheetBackdropState();
}

class _AppGlassSheetBackdropState extends State<AppGlassSheetBackdrop> {
  final _paintKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final session = GlassSheetScope.maybeOf(context);
    final route = ModalRoute.of(context);
    if (session?.hasSnapshot != true || route is! ModalBottomSheetRoute) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: route.animation!,
      child: widget.child,
      builder: (_, child) => CustomPaint(
        key: _paintKey,
        painter: _BackdropPainter(
          session!.snapshot!,
          route.barrierColor.withValues(
            alpha:
                route.barrierColor.a *
                route.barrierCurve.transform(route.animation!.value),
          ),
          () => (_paintKey.currentContext!.findRenderObject()! as RenderBox)
              .localToGlobal(Offset.zero),
        ),
        child: child,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.snapshot, this.dim, this.screenOrigin);
  final GlassSheetSnapshot snapshot;
  final Color dim;
  final Offset Function() screenOrigin;
  @override
  void paint(Canvas canvas, Size size) {
    final origin = screenOrigin() - snapshot.origin;
    final source = Rect.fromLTWH(
      origin.dx * snapshot.ratio,
      origin.dy * snapshot.ratio,
      size.width * snapshot.ratio,
      size.height * snapshot.ratio,
    );
    canvas.drawImageRect(
      snapshot.blurred,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.low,
    );
    canvas.drawRect(Offset.zero & size, Paint()..color = dim);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => true;
}
