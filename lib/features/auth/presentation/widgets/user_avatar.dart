import 'dart:convert';

import 'package:flutter/material.dart';

/// Avatar circular que muestra la foto si existe,
/// o las iniciales del nombre sobre un fondo de color derivado del nombre.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;
  final double fontSize;
  final bool showEditBadge;
  final VoidCallback? onEditTap;

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 50,
    this.fontSize = 28,
    this.showEditBadge = false,
    this.onEditTap,
  });

  static Color _colorFromName(String name) {
    const palette = [
      Color(0xFF6B8E6B),
      Color(0xFF7A9BAF),
      Color(0xFFAF7A8B),
      Color(0xFF9B8FAF),
      Color(0xFF8FAF9B),
      Color(0xFFAF9B7A),
      Color(0xFF7A8FAF),
      Color(0xFFAF7A7A),
    ];
    if (name.isEmpty) return palette[0];
    final hash = name.codeUnits.fold(0, (prev, c) => prev + c);
    return palette[hash % palette.length];
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _hasImage => avatarUrl != null && avatarUrl!.isNotEmpty;

  Widget _buildImage(
    String url,
    double diameter,
    Color bg,
    String initials,
  ) {
    final fallback = _InitialsCircle(
      bg: bg,
      initials: initials,
      diameter: diameter,
      fontSize: fontSize,
    );

    if (url.startsWith('data:')) {
      try {
        final comma = url.indexOf(',');
        if (comma < 0) return fallback;
        final bytes = base64Decode(url.substring(comma + 1));
        return Image.memory(
          bytes,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (context, e, s) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    return Image.network(
      url,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      errorBuilder: (context, e, s) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromName(name);
    final initials = _initials(name);
    final diameter = radius * 2;

    Widget content = _hasImage
        ? _buildImage(avatarUrl!, diameter, bg, initials)
        : _InitialsCircle(
            bg: bg,
            initials: initials,
            diameter: diameter,
            fontSize: fontSize,
          );

    final circle = ClipOval(
      child: SizedBox(width: diameter, height: diameter, child: content),
    );

    if (!showEditBadge) return circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF84D57E),
                shape: BoxShape.circle,
                border: Border.all(color: bg, width: 1.5),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  final Color bg;
  final String initials;
  final double diameter;
  final double fontSize;

  const _InitialsCircle({
    required this.bg,
    required this.initials,
    required this.diameter,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
