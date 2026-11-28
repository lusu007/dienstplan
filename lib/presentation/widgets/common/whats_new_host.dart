import 'package:flutter/widgets.dart';
import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:dienstplan/presentation/widgets/common/release_notes_dialog.dart';
export 'package:dienstplan/presentation/widgets/common/release_notes_dialog.dart'
    show showWhatsNewDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/data/services/whats_new_service.dart';

/// Presents meaningful changes from all missed releases, once after an upgrade.
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
    if (!mounted) return;
    final String current = packageFullVersion(packageInfo);
    final WhatsNewService service = await ref.read(
      whatsNewServiceProvider.future,
    );
    final String? acknowledged = await service.readAcknowledgedVersion();
    final unseen = unseenReleaseNotes(
      acknowledged: acknowledged,
      current: current,
      releases: appReleaseNotes,
    );
    if (!shouldShowWhatsNew(acknowledged: acknowledged, current: current)) {
      await service.writeAcknowledgedVersion(current);
      return;
    }
    if (!mounted) {
      return;
    }
    await showWhatsNewDialog(
      context,
      releases: unseen,
      currentVersion: packageInfo.version,
    );
    if (!mounted) {
      return;
    }
    await service.writeAcknowledgedVersion(current);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
