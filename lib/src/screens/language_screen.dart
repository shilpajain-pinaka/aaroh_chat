import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaroh_chat/src/providers/sdk_chat_provider.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';

/// Simple language selection screen — 3 options: English / Hindi / Hinglish.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final languages = [
      (
        label: 'English',
        subtitle: 'Respond in English',
        icon: '🇬🇧',
        tone: LanguageTone.english,
      ),
      (
        label: 'हिंदी',
        subtitle: 'Hindi में जवाब दें',
        icon: '🇮🇳',
        tone: LanguageTone.hindi,
      ),
      (
        label: 'Hinglish',
        subtitle: 'Mix of Hindi + English',
        icon: '🔀',
        tone: LanguageTone.hinglish,
      ),
    ];

    return Consumer<SdkChatProvider>(
      builder: (context, chat, _) {
        final current = chat.languageTone;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Language',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: languages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final lang = languages[i];
              final selected = current == lang.tone;
              return ListTile(
                tileColor: selected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: selected
                      ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                      : BorderSide.none,
                ),
                leading: Text(lang.icon, style: const TextStyle(fontSize: 28)),
                title: Text(
                  lang.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(lang.subtitle),
                trailing: selected
                    ? Icon(Icons.check_circle_rounded,
                        color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  chat.setLanguage(lang.tone);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
