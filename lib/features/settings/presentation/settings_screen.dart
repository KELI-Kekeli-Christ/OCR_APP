import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ocr_provider_type.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _healthOk = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageProvider);
    final url = await storage.getBackendUrl();
    final token = await storage.getApiToken();
    _urlController.text = url ?? AppConstants.defaultBackendUrl;
    _tokenController.text = token ?? '';
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    final ok = await ref.read(ocrServiceProvider).checkHealth();
    if (mounted) setState(() => _healthOk = ok);
  }

  Future<void> _save() async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveBackendUrl(_urlController.text.trim());
    await storage.saveApiToken(_tokenController.text.trim());
    ref.read(dioClientProvider).updateBaseUrl(_urlController.text.trim());
    ref.read(dioClientProvider).updateToken(_tokenController.text.trim());
    await _checkHealth();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres enregistrés')),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(ocrProviderTypeProvider);
    final studentMode = ref.watch(studentModeProvider);
    final cloudSync = ref.watch(cloudSyncEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Moteur OCR'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _healthOk ? Icons.check_circle : Icons.error_outline,
                    color: _healthOk ? AppColors.success : AppColors.warning,
                  ),
                  title: const Text('EasyOCR (local GPU) + DeepSeek Vision (optionnel)'),
                  subtitle: Text(
                    _healthOk ? 'Backend connecté — OCR réel actif' : 'Backend hors ligne — démarrer le serveur',
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<OcrProviderType>(
                    value: provider,
                    decoration: const InputDecoration(labelText: 'Provider actif'),
                    items: OcrProviderType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.displayName),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(ocrProviderTypeProvider.notifier).state = v;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Connexion API'),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL Backend',
              hintText: 'http://10.0.2.2:8000',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Token API (optionnel)',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            child: const Text('Enregistrer & tester'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Fonctionnalités'),
          SwitchListTile(
            title: const Text('Mode étudiant'),
            subtitle: const Text('Priorise math et documents académiques'),
            value: studentMode,
            onChanged: (v) =>
                ref.read(studentModeProvider.notifier).state = v,
          ),
          SwitchListTile(
            title: const Text('Synchronisation cloud'),
            subtitle: const Text('Sync historique (à connecter)'),
            value: cloudSync,
            onChanged: (v) =>
                ref.read(cloudSyncEnabledProvider.notifier).state = v,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'À propos'),
          const ListTile(
            title: Text('Modèle'),
            subtitle: Text(AppConstants.deepSeekModelId),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
