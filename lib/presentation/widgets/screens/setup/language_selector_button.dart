import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';

/// Glass-styled language switcher shown in the setup header.
///
/// Rolls through supported locales on tap. Visual style matches the other
/// glass pill controls (Today button, month chip, etc.).
class LanguageSelectorButton extends StatelessWidget {
  final LanguageService languageService;
  final VoidCallback? onLanguageChanged;
  final bool disabled;

  const LanguageSelectorButton({
    super.key,
    required this.languageService,
    this.onLanguageChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageService,
      builder: (context, child) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        final Color foreground = Theme.of(context).colorScheme.onSurface;
        final double opacity = disabled ? 0.5 : 1.0;
        final String label = languageService.currentLocale.languageCode == 'de'
            ? l10n.german
            : l10n.english;

        return GlassButtonSurface(
          onTap: () {
            const List<Locale> locales = <Locale>[Locale('de'), Locale('en')];
            final int currentIndex = locales.indexOf(
              languageService.currentLocale,
            );
            final int nextIndex = (currentIndex + 1) % locales.length;
            languageService.setLanguage(locales[nextIndex].languageCode);
            onLanguageChanged?.call();
          },
          enabled: !disabled,
          borderRadius: 999,
          height: 38,
          opacity: opacity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: foreground.withValues(alpha: opacity),
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        );
      },
    );
  }
}
