import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class AbayIcon extends StatelessWidget {
  /// Helper to convert relative backend paths to absolute URLs
  static String? getAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;

    // Handle both /uploads and uploads
    if (path.startsWith('/uploads')) {
      return 'https://abayequb.ahadubingo.com$path';
    }
    if (path.startsWith('uploads')) {
      return 'https://abayequb.ahadubingo.com/$path';
    }

    return path;
  }

  /// Helper to get the correct ImageProvider for a path
  static ImageProvider getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo.png'); // Fallback asset
    }

    final absoluteUrl = getAbsoluteUrl(path);
    if (absoluteUrl == null) return const AssetImage('assets/images/logo.png');

    if (absoluteUrl.startsWith('http')) {
      return NetworkImage(absoluteUrl);
    }

    // Check if it's a local file path
    if (absoluteUrl.startsWith('/') ||
        absoluteUrl.contains(':\\') ||
        absoluteUrl.startsWith('file://')) {
      return FileImage(File(absoluteUrl.replaceFirst('file://', '')));
    }

    return AssetImage(absoluteUrl);
  }

  final String? iconPath;
  final String? name; // Added to allow smart fallbacks
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AbayIcon({
    super.key,
    this.iconPath,
    this.name,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // If we have no path, try to find a smart fallback icon based on the name
    if (iconPath == null || iconPath!.isEmpty) {
      return _getFallbackIcon(name, width, color);
    }

    String? finalPath = getAbsoluteUrl(iconPath);
    if (finalPath == null) return _getFallbackIcon(name, width, color);

    if (finalPath.startsWith('http')) {
      return Image.network(
        finalPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _getFallbackIcon(name, width, color);
        },
      );
    } else if (finalPath.endsWith('.svg')) {
      return SvgPicture.asset(
        finalPath,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
      );
    } else {
      return Image.asset(
        finalPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _getFallbackIcon(name, width, color);
        },
      );
    }
  }

  Widget _getFallbackIcon(String? name, double? size, Color? iconColor) {
    IconData iconData = Icons.inventory_2_rounded;
    final normalizedName = name?.toLowerCase() ?? '';

    if (normalizedName.contains('premium')) {
      iconData = Icons.workspace_premium_rounded;
    } else if (normalizedName.contains('diaspora')) {
      iconData = Icons.public_rounded;
    } else if (normalizedName.contains('female')) {
      iconData = Icons.face_3_rounded;
    } else if (normalizedName.contains('driver')) {
      iconData = Icons.directions_car_rounded;
    } else if (normalizedName.contains('employee')) {
      iconData = Icons.badge_rounded;
    } else if (normalizedName.contains('merchant')) {
      iconData = Icons.storefront_rounded;
    } else if (normalizedName.contains('student')) {
      iconData = Icons.school_rounded;
    } else if (normalizedName.contains('saving')) {
      iconData = Icons.savings_rounded;
    } else if (normalizedName.contains('gold') ||
        normalizedName.contains('diamond')) {
      iconData = Icons.workspace_premium_rounded;
    } else if (normalizedName.contains('business') ||
        normalizedName.contains('pro')) {
      iconData = Icons.business_center_rounded;
    } else if (normalizedName.contains('personal') ||
        normalizedName.contains('individual')) {
      iconData = Icons.person_rounded;
    } else if (normalizedName.contains('family') ||
        normalizedName.contains('group')) {
      iconData = Icons.groups_rounded;
    }

    return Icon(
      iconData,
      color: iconColor ?? Colors.grey.shade400,
      size: size ?? 24,
    );
  }
}
