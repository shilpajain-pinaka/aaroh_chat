import 'package:flutter/material.dart';
import 'package:aaroh_chat/src/models/aaroh_config.dart';

/// Welcome card shown when the chat is empty.
/// Displays company name + greeting + quick-start suggestions.
class SdkWelcomeCard extends StatelessWidget {
  const SdkWelcomeCard({
    super.key,
    required this.config,
    required this.onSuggestionTap,
  });

  final AarohConfig config;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final greeting = config.botGreeting ??
        'Hi! I\'m the ${config.companyName} assistant. How can I help you today?';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo / avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: config.companyLogoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        config.companyLogoUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _initial(config.companyName, theme, 32),
                      ),
                    )
                  : _initial(config.companyName, theme, 32),
            ),
            const SizedBox(height: 20),

            // Company name
            Text(
              config.companyName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Greeting
            Text(
              greeting,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Quick start suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions(config).map((s) {
                return ActionChip(
                  label: Text(s),
                  onPressed: () => onSuggestionTap(s),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial(String name, ThemeData theme, double size) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'A',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  List<String> _suggestions(AarohConfig config) {
    // Use first item from knowledge base as hint, else defaults
    if (config.knowledgeBase.isNotEmpty) {
      return [
        'What can you help me with?',
        'Tell me about ${config.companyName}',
        'How does this work?',
      ];
    }
    return [
      'What can you help me with?',
      'Tell me something useful',
      'How do I get started?',
    ];
  }
}
