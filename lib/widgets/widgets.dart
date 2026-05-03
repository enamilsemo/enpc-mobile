// ─────────────────────────────────────────────────────────────────────────────
// ENPC Mobile — Shared Widgets & Theme
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/models.dart';
import '../services/api.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────

class EnpcTheme {
  static const Color ink = Color(0xFF0E0E0E);
  static const Color ink2 = Color(0xFF2C2C2C);
  static const Color ink3 = Color(0xFF5A5A5A);
  static const Color paper = Color(0xFFF5F3EF);
  static const Color paper2 = Color(0xFFEDEAE3);
  static const Color border = Color(0xFFD4CFC6);
  static const Color accent = Color(0xFFC8392B);
  static const Color gold = Color(0xFFB8860B);
  static const Color green = Color(0xFF2D6A4F);
  static const Color blue = Color(0xFF1A4A7A);

  static Color roleColor(String role) {
    if (role == 'SUPER_ADMIN') return const Color(0xFFB8860B);
    if (role == 'ADMIN') return const Color(0xFF1A4A7A);
    return const Color(0xFF2D6A4F);
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          surface: paper,
        ),
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          headlineLarge: GoogleFonts.dmSerifDisplay(color: ink),
          headlineMedium: GoogleFonts.dmSerifDisplay(color: ink),
          headlineSmall: GoogleFonts.dmSerifDisplay(color: ink),
          titleLarge: GoogleFonts.dmSerifDisplay(color: ink),
        ),
        scaffoldBackgroundColor: paper,
        appBarTheme: AppBarTheme(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.dmSerifDisplay(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: border),
          ),
          margin: const EdgeInsets.only(bottom: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: ink, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ink,
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle:
                GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ink,
            side: const BorderSide(color: border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: paper2,
          labelStyle: GoogleFonts.dmSans(fontSize: 11, color: ink3),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ink,
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF888888),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

// ── Category badge colors ──────────────────────────────────────────────────────

Color categoryColor(String cat) {
  switch (cat) {
    case 'Urgent':
      return const Color(0xFFFEF3C7);
    case 'Academic':
      return const Color(0xFFDBEAFE);
    case 'Events':
      return const Color(0xFFDCFCE7);
    case 'Administrative':
      return const Color(0xFFF3E8FF);
    default:
      return const Color(0xFFEDEAE3);
  }
}

Color categoryTextColor(String cat) {
  switch (cat) {
    case 'Urgent':
      return const Color(0xFF92400E);
    case 'Academic':
      return const Color(0xFF1E40AF);
    case 'Events':
      return const Color(0xFF166534);
    case 'Administrative':
      return const Color(0xFF6B21A8);
    default:
      return const Color(0xFF5A5A5A);
  }
}

// ── Avatar Widget ─────────────────────────────────────────────────────────────

class UserAvatar extends StatelessWidget {
  final User user;
  final double size;

  const UserAvatar({super.key, required this.user, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: EnpcTheme.roleColor(user.role),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: GoogleFonts.dmSans(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    String label;
    switch (role) {
      case 'SUPER_ADMIN':
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFF713F12);
        label = 'Super Admin';
        break;
      case 'ADMIN':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1E40AF);
        label = 'Admin';
        break;
      default:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF166534);
        label = 'Student';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w600, color: text)),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final String category;
  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: categoryColor(category),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: categoryTextColor(category),
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: EnpcTheme.ink)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: EnpcTheme.ink3),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: EnpcTheme.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(message,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: EnpcTheme.accent))),
        if (onRetry != null)
          TextButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style:
                      GoogleFonts.dmSans(color: EnpcTheme.accent, fontSize: 13))),
      ]),
    );
  }
}

// ── Loading Spinner ───────────────────────────────────────────────────────────

class EnpcLoader extends StatelessWidget {
  const EnpcLoader({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(
          color: EnpcTheme.ink, strokeWidth: 2));
}

// ── Section Header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(children: [
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.12,
                  color: EnpcTheme.ink3)),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
      );
}

// ── Utility ───────────────────────────────────────────────────────────────────

String fmtTimeAgo(DateTime dt) => timeago.format(dt, allowFromNow: true);

String fmtDate(DateTime dt) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String fileIcon(String type) {
  switch (type) {
    case 'image': return '🖼️';
    case 'pdf': return '📄';
    case 'doc': return '📝';
    case 'sheet': return '📊';
    case 'ppt': return '📑';
    default: return '📎';
  }
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
    backgroundColor: error ? EnpcTheme.accent : EnpcTheme.ink,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    margin: const EdgeInsets.all(12),
  ));
}
