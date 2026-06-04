import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ocr_mode.dart';
import '../../../domain/entities/scan_result.dart';

final historyProvider = FutureProvider<List<ScanResult>>((ref) async {
  return ref.read(scanRepositoryProvider).getHistory();
});

final favoritesProvider = FutureProvider<List<ScanResult>>((ref) async {
  return ref.read(scanRepositoryProvider).getFavorites();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tous'),
              Tab(text: 'Favoris'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ScanList(provider: historyProvider),
            _ScanList(provider: favoritesProvider),
          ],
        ),
      ),
    );
  }
}

class _ScanList extends ConsumerWidget {
  const _ScanList({required this.provider});

  final FutureProvider<List<ScanResult>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);

    return async.when(
      data: (scans) {
        if (scans.isEmpty) {
          return const Center(
            child: Text('Aucun scan enregistré', style: TextStyle(color: AppColors.textMuted)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(provider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (_, i) {
              final scan = scans[i];
              return Dismissible(
                key: ValueKey(scan.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await ref.read(scanRepositoryProvider).delete(scan.id);
                  ref.invalidate(provider);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceElevated,
                    child: Icon(
                      scan.isFavorite ? Icons.star : Icons.description,
                      color: scan.isFavorite ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                  title: Text(scan.title ?? scan.mode.label),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy • HH:mm').format(scan.createdAt),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      scan.isFavorite ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                    ),
                    onPressed: () async {
                      await ref.read(scanRepositoryProvider).toggleFavorite(scan.id);
                      ref.invalidate(historyProvider);
                      ref.invalidate(favoritesProvider);
                    },
                  ),
                  onTap: () => context.push(AppRoutes.result, extra: scan),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}
