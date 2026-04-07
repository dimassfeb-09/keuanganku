import 'package:flutter/material.dart';

enum DeviceType {
  smallPhone,
  mediumPhone,
  largePhone,
  smallTablet,
  mediumTablet,
  largeTablet,
}

class AppResponsive {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;

  AppResponsive({
    required this.context,
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
  });

  factory AppResponsive.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return AppResponsive(
      context: context,
      screenWidth: mediaQuery.size.width,
      screenHeight: mediaQuery.size.height,
      orientation: mediaQuery.orientation,
    );
  }

  DeviceType get screenType {
    if (screenWidth < 360) return DeviceType.smallPhone;
    if (screenWidth < 480) return DeviceType.mediumPhone;
    if (screenWidth < 600) return DeviceType.largePhone;
    if (screenWidth < 720) return DeviceType.smallTablet;
    if (screenWidth < 960) return DeviceType.mediumTablet;
    return DeviceType.largeTablet;
  }

  bool get isTablet => screenWidth >= 600;
  bool get isLargeScreen => screenWidth >= 720;
  bool get isLandscape => orientation == Orientation.landscape;

  // Spacing & Padding
  EdgeInsets get pagePadding {
    double horizontal = 16.0;
    if (screenWidth >= 960) {
      horizontal = 32.0;
    } else if (screenWidth >= 600) {
      horizontal = 24.0;
    }
    
    // Add extra padding for landscape on tablets
    if (isLandscape && isTablet) {
      horizontal += 8.0;
    }

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16.0);
  }

  EdgeInsets get cardPadding {
    if (screenWidth >= 720) return const EdgeInsets.all(24.0);
    return const EdgeInsets.all(16.0);
  }

  double get sectionSpacing => isTablet ? 32.0 : 24.0;
  double get itemSpacing => isTablet ? 16.0 : 12.0;

  // Navigation Sizes
  double get navRailMinWidth => isTablet ? (screenWidth < 840 ? 88.0 : 72.0) : 72.0;
  double get navRailIconSize => isTablet ? 32.0 : 24.0;

  // Icon sizing
  double get iconSize => isTablet ? 28.0 : 24.0;
  double get smallIconSize => isTablet ? 24.0 : 20.0;

  // Typography Scaling
  double get displayFontSize {
    if (screenWidth < 360) return 28.0;
    if (screenWidth < 600) return 32.0;
    if (screenWidth < 960) return 38.0;
    return 42.0;
  }

  double get titleFontSize {
    if (screenWidth < 600) return 18.0;
    if (screenWidth < 960) return 22.0;
    return 26.0;
  }

  double get bodyFontSize => isTablet ? 16.0 : 14.0;
  double get captionFontSize => isTablet ? 13.0 : 11.0;

  // Grid & Component
  double get walletCardWidth {
    if (screenWidth < 360) return screenWidth * 0.85;
    if (screenWidth < 600) return 300.0;
    return 340.0;
  }

  double get walletListHeight {
    if (isTablet) return 200.0;
    return 156.0;
  }

  int get gridCrossAxisCount {
    if (screenWidth < 360) return 3;
    if (screenWidth < 600) return 4;
    if (screenWidth < 960) return 5;
    return 6;
  }

  double get maxContentWidth => isTablet ? 600.0 : double.infinity;

  double get fabSize => isTablet ? 64.0 : 56.0;
}
