import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders assistant/user message text with proper spacing, paragraphs, and bullets.
class FormattedMessageText extends StatelessWidget {
  const FormattedMessageText({
    super.key,
    required this.text,
    required this.color,
    this.isStreaming = false,
  });

  final String text;
  final Color color;
  final bool isStreaming;

  TextStyle _baseStyle(BuildContext context) {
    return GoogleFonts.notoSans(
      fontSize: 15.5,
      height: 1.65,
      letterSpacing: 0.1,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty && isStreaming) {
      return Text('...', style: _baseStyle(context));
    }

    final blocks = text.split('\n\n');
    final children = <Widget>[];

    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i].trim();
      if (block.isEmpty) continue;

      final lines = block.split('\n');
      final isBulletBlock = lines.every(
        (line) => line.trim().isEmpty || _isBulletLine(line),
      );

      if (isBulletBlock && lines.any(_isBulletLine)) {
        children.add(_BulletBlock(
          lines: lines.where((l) => l.trim().isNotEmpty).toList(),
          style: _baseStyle(context),
        ));
      } else {
        children.add(Text(block, style: _baseStyle(context)));
      }

      if (i < blocks.length - 1) {
        children.add(const SizedBox(height: 12));
      }
    }

    if (children.isEmpty) {
      return Text(text, style: _baseStyle(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  bool _isBulletLine(String line) {
    final trimmed = line.trimLeft();
    return trimmed.startsWith('•') ||
        trimmed.startsWith('-') ||
        trimmed.startsWith('*') ||
        RegExp(r'^\d+\.').hasMatch(trimmed);
  }
}

class _BulletBlock extends StatelessWidget {
  const _BulletBlock({
    required this.lines,
    required this.style,
  });

  final List<String> lines;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trimLeft();
        final bulletMatch = RegExp(r'^[•\-*]\s*').firstMatch(trimmed);
        final numberedMatch = RegExp(r'^\d+\.\s*').firstMatch(trimmed);
        final match = bulletMatch ?? numberedMatch;

        final content = match != null ? trimmed.substring(match.end) : trimmed;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Text(
                  match != null && numberedMatch != null
                      ? trimmed.substring(0, match.end).trim()
                      : '•',
                  style: style.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              Expanded(child: Text(content, style: style)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
