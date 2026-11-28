import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Shares the app's theme and labels with dependencies using SDK design widgets.
/// Remove these temporary bridges once those dependencies migrate as well.
class AppUiCompatibility extends StatelessWidget {
  const AppUiCompatibility({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(
      // ignore: deprecated_member_use
      child: CupertinoUiCompatibilityBridge(child: child),
    );
  }
}
