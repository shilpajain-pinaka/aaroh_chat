import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aaroh_chat/src/models/user_settings.dart';

class AppTheme {
  AppTheme._();

  static TextStyle brandTitleStyle(Color color) {
    return GoogleFonts.lora(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle messageStyle({
    required Color color,
    double fontSize = 15.5,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.notoSans(
      fontSize: fontSize,
      height: 1.65,
      letterSpacing: 0.1,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static ThemeData build(UserSettings settings) {
    final brightness = settings.isDarkMode ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.seedColor,
      brightness: brightness,
      surface: settings.isDarkMode
          ? const Color(0xFF1A1A1F)
          : const Color(0xFFFAFAF8),
    );

    final baseTextTheme = GoogleFonts.notoSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final scaledTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize:
            (baseTextTheme.displayLarge?.fontSize ?? 57) * settings.fontScale,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize:
            (baseTextTheme.displayMedium?.fontSize ?? 45) * settings.fontScale,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize:
            (baseTextTheme.displaySmall?.fontSize ?? 36) * settings.fontScale,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize:
            (baseTextTheme.headlineLarge?.fontSize ?? 32) * settings.fontScale,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize:
            (baseTextTheme.headlineMedium?.fontSize ?? 28) * settings.fontScale,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize:
            (baseTextTheme.headlineSmall?.fontSize ?? 24) * settings.fontScale,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize:
            (baseTextTheme.titleLarge?.fontSize ?? 22) * settings.fontScale,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize:
            (baseTextTheme.titleMedium?.fontSize ?? 16) * settings.fontScale,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize:
            (baseTextTheme.titleSmall?.fontSize ?? 14) * settings.fontScale,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize:
            (baseTextTheme.bodyLarge?.fontSize ?? 16) * settings.fontScale,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize:
            (baseTextTheme.bodyMedium?.fontSize ?? 14) * settings.fontScale,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize:
            (baseTextTheme.bodySmall?.fontSize ?? 12) * settings.fontScale,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize:
            (baseTextTheme.labelLarge?.fontSize ?? 14) * settings.fontScale,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize:
            (baseTextTheme.labelMedium?.fontSize ?? 12) * settings.fontScale,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize:
            (baseTextTheme.labelSmall?.fontSize ?? 11) * settings.fontScale,
      ),
    );

    final scaffoldBg =
        settings.isDarkMode ? const Color(0xFF121218) : const Color(0xFFFAFAF8);

    final userBubbleColor = settings.isDarkMode
        ? colorScheme.primaryContainer
        : const Color(0xFFF0EBE3);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: scaledTextTheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [
        ChatColors(
          userBubble: userBubbleColor,
          userBubbleText: settings.isDarkMode
              ? colorScheme.onPrimaryContainer
              : const Color(0xFF1A1A1A),
          assistantText: colorScheme.onSurface,
          inputBackground: settings.isDarkMode
              ? colorScheme.surfaceContainerHigh
              : Colors.white,
        ),
      ],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: brandTitleStyle(colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: settings.isDarkMode
            ? colorScheme.surfaceContainerHighest
            : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: settings.isDarkMode
            ? colorScheme.surfaceContainerHigh
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ChatColors chatColors(BuildContext context) {
    return Theme.of(context).extension<ChatColors>()!;
  }

  static String presetLabel(ThemePreset preset) => switch (preset) {
        ThemePreset.warmSunset => 'Warm Sunset',
        ThemePreset.calmOcean => 'Calm Ocean',
        ThemePreset.forestPeace => 'Forest Peace',
        ThemePreset.lavenderDream => 'Lavender Dream',
        ThemePreset.midnightCalm => 'Midnight Calm',
      };

  static String toneLabel(LanguageTone tone) => switch (tone) {
        LanguageTone.hinglish => 'Hinglish',
        LanguageTone.hindi => 'Hindi',
        LanguageTone.english => 'English',
      };

  static String depthLabel(ResponseDepth depth) => switch (depth) {
        ResponseDepth.brief => 'Brief',
        ResponseDepth.balanced => 'Balanced',
        ResponseDepth.detailed => 'Detailed',
      };

  static String depthDescription(ResponseDepth depth) => switch (depth) {
        ResponseDepth.brief => 'Short, quick replies (3-4 lines)',
        ResponseDepth.balanced => 'Default — empathy + tips + question',
        ResponseDepth.detailed => 'More context and extra suggestions',
      };
}

class ChatColors extends ThemeExtension<ChatColors> {
  const ChatColors({
    required this.userBubble,
    required this.userBubbleText,
    required this.assistantText,
    required this.inputBackground,
  });

  final Color userBubble;
  final Color userBubbleText;
  final Color assistantText;
  final Color inputBackground;

  @override
  ChatColors copyWith({
    Color? userBubble,
    Color? userBubbleText,
    Color? assistantText,
    Color? inputBackground,
  }) {
    return ChatColors(
      userBubble: userBubble ?? this.userBubble,
      userBubbleText: userBubbleText ?? this.userBubbleText,
      assistantText: assistantText ?? this.assistantText,
      inputBackground: inputBackground ?? this.inputBackground,
    );
  }

  @override
  ChatColors lerp(ThemeExtension<ChatColors>? other, double t) {
    if (other is! ChatColors) return this;
    return ChatColors(
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      userBubbleText: Color.lerp(userBubbleText, other.userBubbleText, t)!,
      assistantText: Color.lerp(assistantText, other.assistantText, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
    );
  }
}
