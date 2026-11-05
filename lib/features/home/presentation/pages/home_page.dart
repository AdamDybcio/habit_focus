import 'package:habit_focus/core/config/flavor.dart';
import 'package:habit_focus/core/theme/app_spacing.dart';
import 'package:habit_focus/core/theme/theme_context.dart';
import 'package:habit_focus/core/ui/flavor_badge.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Landing screen shown until the real features are built.
class HomePage extends StatelessWidget {
  /// Creates the home page for the given build [flavor].
  const new({required this.flavor, super.key});

  /// Environment the app runs in. Non-production builds show a badge.
  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (flavor != Flavor.prod) ...[
                FlavorBadge(flavor: flavor),
                const SizedBox(height: AppSpacing.m),
              ],
              Text(l10n.appTitle, style: context.text.displaySmall),
              const SizedBox(height: AppSpacing.s),
              Text(l10n.homeTagline, style: context.text.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
