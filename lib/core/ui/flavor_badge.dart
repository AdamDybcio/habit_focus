import 'package:habit_focus/core/config/flavor.dart';
import 'package:habit_focus/core/theme/app_radius.dart';
import 'package:habit_focus/core/theme/app_spacing.dart';
import 'package:habit_focus/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

/// Small pill telling testers which environment they are looking at.
class FlavorBadge extends StatelessWidget {
  /// Creates a badge for the given [flavor].
  const new({required this.flavor, super.key});

  /// Environment to display.
  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          flavor.name.toUpperCase(),
          style: context.text.labelMedium?.copyWith(
            color: colors.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
