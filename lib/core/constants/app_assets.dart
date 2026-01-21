import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_colors.dart';

/// Central definition of app image and SVG asset paths.
/// Use [navIcon] to render bottom nav bar icons with active/inactive tint.
abstract class AppAssets {
  AppAssets._();

  // --- Bottom navigation bar icons (SVG) ---
  static const String iconsDashboard = 'assets/icons/dashboard.svg';
  static const String iconsWatch = 'assets/icons/watch.svg';
  static const String iconsMediaLibrary = 'assets/icons/mediaLibrary.svg';
  static const String iconsMore = 'assets/icons/more.svg';

  // --- Seat icon (SVG) ---
  static const String iconsSeat = 'assets/icons/seat.svg';

  // --- Font family ---
  static const String fontFamilyPoppins = 'Poppins';

  /// Renders an SVG with a solid color tint (e.g. for seat icons).
  static Widget svgWithColor(
    String assetPath, {
    required Color color,
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Renders an SVG nav bar icon with active (white) or inactive (grey) color.
  static Widget navIcon(
    String assetPath, {
    required bool isActive,
    double size = 24,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        isActive ? Colors.white : AppColors.textMuted,
        BlendMode.srcIn,
      ),
    );
  }
}
