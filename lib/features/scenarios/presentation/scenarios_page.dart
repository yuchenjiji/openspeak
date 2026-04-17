import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/scenario.dart';
import '../../chat/domain/providers.dart';
import 'widgets/scenario_card.dart';

class ScenariosPage extends ConsumerStatefulWidget {
  const ScenariosPage({super.key});

  @override
  ConsumerState<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends ConsumerState<ScenariosPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [null, ...ScenarioCategory.values];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allScenarios = ref.watch(allScenariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((cat) {
            return Tab(
              icon: cat == null ? null : Icon(cat.iconData, size: 18),
              text: cat == null ? 'All' : cat.label,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((cat) {
          final scenarios = cat == null
              ? allScenarios
              : allScenarios.where((s) => s.category == cat).toList();
          return _ScenarioGrid(scenarios: scenarios);
        }).toList(),
      ),
    );
  }
}

class _ScenarioGrid extends StatelessWidget {
  final List<Scenario> scenarios;
  const _ScenarioGrid({required this.scenarios});

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const Center(child: Text('No scenarios available.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: scenarios.length,
      itemBuilder: (context, i) => ScenarioCard(
        scenario: scenarios[i],
        onTap: () => context.push('/chat/${scenarios[i].id}'),
      ),
    );
  }
}
