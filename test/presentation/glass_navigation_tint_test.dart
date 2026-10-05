import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

void main() {
  testWidgets(
    'light month and back surfaces stay neutral across accent colors',
    (tester) async {
      for (final accent in [AppColors.primary, Colors.pink]) {
        final scheme = ThemeData.light().colorScheme.copyWith(primary: accent);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: Scaffold(
              body: Column(
                children: [
                  GlassPickerPillTrigger(label: 'Oktober 2026', onTap: () {}),
                  AppGlassIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Zurück',
                    onPressed: () {},
                  ),
                  AppGlassButton(
                    role: AppGlassButtonRole.secondary,
                    onPressed: () {},
                    child: const Text('Aktion'),
                  ),
                ],
              ),
            ),
          ),
        );
        for (final button in tester.widgetList<liquid.GlassButton>(
          find.byType(liquid.GlassButton),
        )) {
          expect(
            button.settings!.glassColor.withValues(alpha: 1),
            scheme.surface,
          );
        }
        final back = tester.widget<liquid.GlassIconButton>(
          find.byType(liquid.GlassIconButton),
        );
        expect(back.settings!.glassColor.withValues(alpha: 1), scheme.surface);
      }
    },
  );
}
