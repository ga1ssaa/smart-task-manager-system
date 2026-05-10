import 'dart:io';

import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final bool isLoading;

  const AvatarWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 40,
    this.onTap,
    this.showEditIcon = false,
    this.isLoading = false,
  });

  ImageProvider? _resolveImage() {
    if (photoUrl == null || photoUrl!.isEmpty) return null;
    if (photoUrl!.startsWith('http')) return NetworkImage(photoUrl!);
    final file = File(photoUrl!);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);
    final imageProvider = _resolveImage();

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: imageProvider != null
                  ? Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Initials(name: name, radius: radius, color: primaryColor),
                    )
                  : _Initials(name: name, radius: radius, color: primaryColor),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.6,
                height: radius * 0.6,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: radius * 0.32,
                  color: Colors.white,
                ),
              ),
            ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0x55000000),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double radius;
  final Color color;

  const _Initials({
    required this.name,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.55,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
