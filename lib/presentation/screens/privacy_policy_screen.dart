import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<String> _markdownFuture;

  @override
  void initState() {
    super.initState();
    _markdownFuture = rootBundle.loadString(
      AppInfo.privacyPolicyMarkdownAssetPath,
    );
  }

  static MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      h2: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      p: textTheme.bodyMedium?.copyWith(height: 1.5),
      listBullet: textTheme.bodyMedium,
      a: textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GlassScreenScaffold(
      title: l10n.privacyPolicy,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXxl,
        ),
        child: FutureBuilder<String>(
          future: _markdownFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Text(
                  l10n.privacyPolicyLoadError,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!snapshot.hasData) {
              final double minHeight = MediaQuery.sizeOf(context).height * 0.35;
              return SizedBox(
                height: minHeight,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return MarkdownBody(
              data: snapshot.data!,
              styleSheet: _markdownStyle(context),
              onTapLink: (String text, String? href, String title) {
                _openMarkdownLink(href);
              },
            );
          },
        ),
      ),
    );
  }
}

void _openMarkdownLink(String? href) {
  if (href == null || href.isEmpty) {
    return;
  }
  final Uri uri = Uri.parse(href);
  canLaunchUrl(uri).then((bool allowed) {
    if (allowed) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  });
}
