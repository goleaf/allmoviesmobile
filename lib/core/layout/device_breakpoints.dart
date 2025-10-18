/// Describes coarse device size classes used throughout the UI to adapt
/// layouts for phones, tablets, and desktop experiences.
enum DeviceSizeClass {
  phone,
  tablet,
  desktop,
}

class DeviceBreakpoints {
  const DeviceBreakpoints._();

  static const double tabletMinWidth = 600;
  static const double desktopMinWidth = 1024;

  static DeviceSizeClass sizeClassForWidth(double width) {
    if (width >= desktopMinWidth) {
      return DeviceSizeClass.desktop;
    }
    if (width >= tabletMinWidth) {
      return DeviceSizeClass.tablet;
    }
    return DeviceSizeClass.phone;
  }

  static int columnsForWidth(
    double width, {
    int phone = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    final sizeClass = sizeClassForWidth(width);
    switch (sizeClass) {
      case DeviceSizeClass.phone:
        return phone;
      case DeviceSizeClass.tablet:
        return tablet;
      case DeviceSizeClass.desktop:
        return desktop;
    }
  }

  static double horizontalPaddingForWidth(double width) {
    switch (sizeClassForWidth(width)) {
      case DeviceSizeClass.phone:
        return 16;
      case DeviceSizeClass.tablet:
        return 24;
      case DeviceSizeClass.desktop:
        return 48;
    }
  }
}
