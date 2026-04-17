import 'package:flutter/material.dart';

import '../../../core/theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: themeController,
                builder: (context, _) => _AppearanceSection(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('About'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('OpenSpeak'),
              subtitle: const Text('v1.0.0 — AI-powered English practice'),
              trailing: const Icon(Icons.info_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Mode', style: textTheme.titleSmall),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_rounded),
              label: Text('System'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_rounded),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_rounded),
              label: Text('Dark'),
            ),
          ],
          selected: {themeController.themeMode},
          onSelectionChanged: (s) => themeController.setThemeMode(s.first),
        ),
        const SizedBox(height: 20),
        Text('Color Preset', style: textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ThemePreset.values.map((preset) {
            return FilterChip(
              label: Text(_presetLabel(preset)),
              selected: themeController.preset == preset,
              onSelected: (_) => themeController.setPreset(preset),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _presetLabel(ThemePreset preset) => switch (preset) {
        ThemePreset.dynamic => 'Dynamic',
        ThemePreset.ocean => 'Ocean',
        ThemePreset.sunset => 'Sunset',
        ThemePreset.forest => 'Forest',
        ThemePreset.graphite => 'Graphite',
      };
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
