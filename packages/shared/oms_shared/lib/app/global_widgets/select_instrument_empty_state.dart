import 'package:material_ui/material_ui.dart';

import 'appbar_right_search_tap.dart';

/// Empty state shown when Quote or Trade has no selected market instrument.
class SelectInstrumentEmptyState extends StatelessWidget {
  const SelectInstrumentEmptyState({super.key, required this.targetIndex});

  final int targetIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 40, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'No stock selected',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Search and select a stock to view its details or place an order.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => AppbarRightSearchTapWidget.openAndSelect(
                targetIndex: targetIndex,
              ),
              icon: const Icon(Icons.search),
              label: const Text('Search stocks'),
            ),
          ],
        ),
      ),
    );
  }
}
