import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../widgets/module_card.dart';

class ModulesTab extends StatefulWidget {
  const ModulesTab({super.key});

  @override
  State<ModulesTab> createState() => _ModulesTabState();
}

class _ModulesTabState extends State<ModulesTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter modules based on search query
    final filteredModules = learningModules.where((module) {
      final query = _searchQuery.toLowerCase();
      return module.title.toLowerCase().contains(query) ||
             module.description.toLowerCase().contains(query);
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

          // Responsive Grid/List of Modules
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine columns based on available width
                int crossAxisCount = 1;
                if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 500) {
                  crossAxisCount = 2;
                }

                if (filteredModules.isEmpty) {
                  return const Center(
                    child: Text(
                      'No modules found.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                if (crossAxisCount == 1) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredModules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return ModuleCard(
                        module: filteredModules[index],
                        onTap: () => context.push('/learnings/module-details', extra: filteredModules[index]),
                      );
                    },
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // 100 bottom padding for nav pill
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16, // Replaces the margin we removed from ModuleCard
                    crossAxisSpacing: 16,
                    childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.5, // Taller on mobile, squarer on tablet
                    mainAxisExtent: 220, // Increased height to prevent text overflow
                  ),
                  itemCount: filteredModules.length,
                  itemBuilder: (context, index) {
                    return ModuleCard(
                      module: filteredModules[index],
                      onTap: () => context.push('/learnings/module-details', extra: filteredModules[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
