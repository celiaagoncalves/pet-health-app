import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = context.watch<LocaleService>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _sectionHeader(l.settingsLanguageSection),
          RadioGroup<Locale>(
            groupValue: locale.locale,
            onChanged: (v) {
              if (v != null) locale.setLocale(v);
            },
            child: Column(
              children: LocaleService.supported
                  .map((loc) => RadioListTile<Locale>(
                        value: loc,
                        title: Row(
                          children: [
                            Text(locale.flag(loc),
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(locale.displayName(loc)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(l.settingsLanguageFooter,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          _sectionHeader(l.settingsAboutSection),
          ListTile(
            title: Text(l.settingsAboutVersion),
            trailing: const Text('1.0.0',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600)),
    );
  }
}
