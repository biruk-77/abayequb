import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AbayIcon extends StatelessWidget {
  final String? iconPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AbayIcon({
    super.key,
    this.iconPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (iconPath == null || iconPath!.isEmpty) {
      return Icon(Icons.image_not_supported, color: Colors.grey, size: width);
    }

    if (iconPath!.startsWith('http')) {
      return Image.network(
        iconPath!,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
           return Icon(Icons.error, color: Colors.red, size: width);
        },
      );
    } else if (iconPath!.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath!,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
      );
    } else {
      return Image.asset(
        iconPath!,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
           return Icon(Icons.image_not_supported, color: Colors.grey, size: width);
        },
      );
    }
  }
}
