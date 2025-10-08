import 'package:flutter/material.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';
import 'package:vegolo/features/scanning/data/cache/off_cache.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _saveFullImages;
  bool _loading = true;
  String _offCacheInfo = '…';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = getIt<SettingsRepository>();
    final v = await repo.getSaveFullImages();
    final off = getIt<OffCache>();
    final bytes = await off.sizeBytes();
    final count = await off.itemCount();
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    if (!mounted) return;
    setState(() {
      _saveFullImages = v;
      _loading = false;
      _offCacheInfo = '$count items • $mb MB';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Save full images'),
                  subtitle: const Text(
                      'If off, only thumbnails are stored (recommended).'),
                  value: _saveFullImages ?? false,
                  onChanged: (v) async {
                    setState(() => _saveFullImages = v);
                    await getIt<SettingsRepository>().setSaveFullImages(v);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            v ? 'Full-size image saving enabled' : 'Full-size image saving disabled'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Open Food Facts cache'),
                  subtitle: Text(_offCacheInfo),
                  trailing: TextButton(
                    onPressed: () async {
                      await getIt<OffCache>().clear();
                      await _load();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OFF cache cleared')),
                      );
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
    );
  }
}
