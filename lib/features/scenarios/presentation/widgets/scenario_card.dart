import 'package:flutter/material.dart';

import '../../../../core/models/scenario.dart';

class ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final VoidCallback onTap;

  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.onTap,
  });

  (Color bg, Color fg) _difficultyColors(ColorScheme cs) => switch (scenario.difficulty) {
        ScenarioDifficulty.beginner => (cs.tertiaryContainer, cs.onTertiaryContainer),
        ScenarioDifficulty.intermediate => (cs.secondaryContainer, cs.onSecondaryContainer),
        ScenarioDifficulty.advanced => (cs.errorContainer, cs.onErrorContainer),
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (diffBg, diffFg) = _difficultyColors(colorScheme);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  scenario.iconData,
                  size: 22,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                scenario.title,
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  scenario.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: diffBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scenario.difficulty.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: diffFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
