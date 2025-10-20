import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vegolo/core/ai/generation_options.dart';
import 'package:vegolo/core/di/injection.dart';
import 'package:vegolo/features/settings/domain/repositories/settings_repository.dart';
import 'package:vegolo/features/scanning/data/cache/off_cache.dart';
import 'package:vegolo/core/telemetry/analytics_telemetry_exporter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _saveFullImages;
  bool? _aiEnabled;
  bool? _telemetryEnabled;
  GemmaGenerationOptions? _decodeOptions;
  bool _loading = true;
  String _offCacheInfo = '…';
  String? _legalNotice;
  String? _privacyPolicy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = getIt<SettingsRepository>();
    final v = await repo.getSaveFullImages();
    final ai = await repo.getAiAnalysisEnabled();
    final telemetry = await repo.getTelemetryAnalyticsEnabled();
    final options = await repo.getGemmaGenerationOptions();
    final off = getIt<OffCache>();
    final bytes = await off.sizeBytes();
    final count = await off.itemCount();
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    if (!mounted) return;
    setState(() {
      _saveFullImages = v;
      _aiEnabled = ai;
      _telemetryEnabled = telemetry;
      _decodeOptions = options;
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
                  title: const Text('Enable AI analysis (Gemma 3n)'),
                  subtitle: const Text(
                    'Use on-device Gemma reasoning when the rule engine is uncertain.',
                  ),
                  value: _aiEnabled ?? false,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _aiEnabled = v);
                    await getIt<SettingsRepository>().setAiAnalysisEnabled(v);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'AI-assisted analysis enabled'
                              : 'AI-assisted analysis disabled',
                        ),
                      ),
                    );
                  },
                ),
                if (_decodeOptions != null)
                  ListTile(
                    title: const Text('Gemma generation settings'),
                    subtitle: Text(_formatGenerationSummary(_decodeOptions!)),
                    trailing: const Icon(Icons.tune),
                    onTap: () => _editGenerationOptions(context),
                  ),
                SwitchListTile(
                  title: const Text('Share anonymous Gemma telemetry'),
                  subtitle: const Text(
                    'Send aggregated on-device performance metrics to help improve Vegolo.',
                  ),
                  value: _telemetryEnabled ?? false,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _telemetryEnabled = v);
                    await getIt<SettingsRepository>()
                        .setTelemetryAnalyticsEnabled(v);
                    getIt<AnalyticsTelemetryExporter>().updateOptIn(v);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Telemetry sharing enabled'
                              : 'Telemetry sharing disabled',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Save full images'),
                  subtitle: const Text(
                    'If off, only thumbnails are stored (recommended).',
                  ),
                  value: _saveFullImages ?? false,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _saveFullImages = v);
                    await getIt<SettingsRepository>().setSaveFullImages(v);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Full-size image saving enabled'
                              : 'Full-size image saving disabled',
                        ),
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
                      final messenger = ScaffoldMessenger.of(context);
                      await getIt<OffCache>().clear();
                      await _load();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('OFF cache cleared')),
                      );
                    },
                    child: const Text('Clear'),
                  ),
                ),
                ListTile(
                  title: const Text('Gemma legal notices'),
                  subtitle: const Text(
                    'Gemma 3n terms, policy, and attribution',
                  ),
                  trailing: const Icon(Icons.article_outlined),
                  onTap: _showLegalNotices,
                ),
                ListTile(
                  title: const Text('Privacy policy'),
                  subtitle: const Text(
                    'Telemetry data collection and retention',
                  ),
                  trailing: const Icon(Icons.privacy_tip_outlined),
                  onTap: _showPrivacyPolicy,
                ),
              ],
            ),
    );
  }

  String _formatGenerationSummary(GemmaGenerationOptions options) {
    final temp = options.temperature.toStringAsFixed(2);
    final topP = options.topP.toStringAsFixed(2);
    final seed = options.randomSeed != null
        ? 'seed ${options.randomSeed}'
        : 'seed auto';
    return 'Max ${options.maxTokens} tokens • temp $temp • topP $topP • topK ${options.topK} • $seed';
  }

  Future<void> _editGenerationOptions(BuildContext context) async {
    final current = _decodeOptions ?? GemmaGenerationOptions.defaults;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showModalBottomSheet<GemmaGenerationOptions>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _GemmaGenerationSheet(initial: current),
    );
    if (result == null) return;

    await getIt<SettingsRepository>().setGemmaGenerationOptions(result);
    if (!mounted) return;

    setState(() {
      _decodeOptions = result;
    });

    messenger.showSnackBar(
      const SnackBar(content: Text('Gemma generation settings updated')),
    );
  }

  Future<void> _showLegalNotices() async {
    final text =
        _legalNotice ?? await rootBundle.loadString('GEMMA_LEGAL_NOTICES.txt');
    if (!mounted) return;
    setState(() {
      _legalNotice = text;
    });
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemma legal notices'),
        content: SizedBox(
          width: double.maxFinite,
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyPolicy() async {
    final text =
        _privacyPolicy ??
        await rootBundle.loadString('assets/privacy_policy.txt');
    if (!mounted) return;
    setState(() {
      _privacyPolicy = text;
    });
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy policy'),
        content: SizedBox(
          width: double.maxFinite,
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _GemmaGenerationSheet extends StatefulWidget {
  const _GemmaGenerationSheet({required this.initial});

  final GemmaGenerationOptions initial;

  @override
  State<_GemmaGenerationSheet> createState() => _GemmaGenerationSheetState();
}

class _GemmaGenerationSheetState extends State<_GemmaGenerationSheet> {
  late int _maxTokens;
  late double _temperature;
  late double _topP;
  late int _topK;
  late bool _deterministic;
  late TextEditingController _seedController;
  String? _seedError;

  @override
  void initState() {
    super.initState();
    _maxTokens = widget.initial.maxTokens;
    _temperature = widget.initial.temperature;
    _topP = widget.initial.topP;
    _topK = widget.initial.topK;
    _deterministic = widget.initial.randomSeed != null;
    _seedController = TextEditingController(
      text: widget.initial.randomSeed?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gemma generation settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Max tokens ($_maxTokens)',
            min: 32,
            max: 512,
            divisions: (512 - 32) ~/ 32,
            value: _maxTokens.toDouble(),
            onChanged: (value) => setState(() => _maxTokens = value.round()),
          ),
          _buildSlider(
            label: 'Temperature (${_temperature.toStringAsFixed(2)})',
            min: 0.0,
            max: 1.5,
            divisions: 30,
            value: _temperature,
            onChanged: (value) => setState(() => _temperature = value),
          ),
          _buildSlider(
            label: 'Top-p (${_topP.toStringAsFixed(2)})',
            min: 0.1,
            max: 1.0,
            divisions: 18,
            value: _topP,
            onChanged: (value) => setState(() => _topP = value),
          ),
          _buildSlider(
            label: 'Top-k ($_topK)',
            min: 1,
            max: 200,
            divisions: 199,
            value: _topK.toDouble(),
            onChanged: (value) => setState(() => _topK = value.round()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Deterministic output'),
            subtitle: const Text(
              'Use a fixed random seed to make responses repeatable',
            ),
            value: _deterministic,
            onChanged: (value) {
              setState(() {
                _deterministic = value;
                if (!value) {
                  _seedController.clear();
                  _seedError = null;
                }
              });
            },
          ),
          if (_deterministic)
            TextField(
              controller: _seedController,
              decoration: InputDecoration(
                labelText: 'Random seed',
                helperText: 'Leave empty to disable deterministic mode',
                errorText: _seedError,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_seedError != null) {
                  setState(() => _seedError = null);
                }
              },
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double min,
    required double max,
    required int divisions,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _submit() {
    int? seed;
    if (_deterministic) {
      final raw = _seedController.text.trim();
      if (raw.isEmpty) {
        setState(
          () =>
              _seedError = 'Enter a seed value or disable deterministic mode.',
        );
        return;
      }
      final parsed = int.tryParse(raw);
      if (parsed == null) {
        setState(() => _seedError = 'Seed must be a valid integer.');
        return;
      }
      seed = parsed;
    }

    final options = GemmaGenerationOptions(
      maxTokens: _maxTokens,
      temperature: _temperature,
      topP: _topP,
      topK: _topK,
      randomSeed: seed,
    );
    Navigator.of(context).pop(options);
  }
}
