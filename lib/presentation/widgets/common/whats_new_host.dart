import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/whats_new_service.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';

/// Opens the localized what's-new dialog (same UI as after an app update).
Future<void> showWhatsNewDialog(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  await GlassAppDialog.show<void>(
    context: context,
    barrierDismissible: true,
    title: l10n.whatsNewTitle,
    content: SingleChildScrollView(child: Text(l10n.whatsNewBody)),
    actions: <Widget>[
      GlassButtonSurface(
        onTap: () => Navigator.of(context).pop(),
        enabled: true,
        borderRadius: glassSurfaceRadiusSm,
        height: 48,
        fullWidth: true,
        tintOpacity: isDark
            ? glassTintAlphaActiveDark
            : glassTintAlphaActiveLight,
        borderOpacity: glassBorderAlphaActive,
        child: Center(
          child: Text(
            l10n.whatsNewGotIt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Shows the post-update „what's new“ dialog once when the app version changed.
class WhatsNewHost extends ConsumerStatefulWidget {
  const WhatsNewHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WhatsNewHost> createState() => _WhatsNewHostState();
}

class _WhatsNewHostState extends ConsumerState<WhatsNewHost> {
  bool _startedCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowWhatsNew();
    });
  }

  Future<void> _maybeShowWhatsNew() async {
    if (_startedCheck || !mounted) {
      return;
    }
    _startedCheck = true;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String current = packageFullVersion(packageInfo);
    final WhatsNewService service = await ref.read(
      whatsNewServiceProvider.future,
    );
    final String? acknowledged = await service.readAcknowledgedVersion();
    if (acknowledged == null) {
      await service.writeAcknowledgedVersion(current);
      return;
    }
    if (!shouldShowWhatsNew(acknowledged: acknowledged, current: current)) {
      return;
    }
    if (!mounted) {
      return;
    }
    await showWhatsNewDialog(context);
    if (!mounted) {
      return;
    }
    await service.writeAcknowledgedVersion(current);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
