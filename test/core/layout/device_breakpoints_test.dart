import 'package:flutter_test/flutter_test.dart';

import 'package:allmoviesmobile/core/layout/device_breakpoints.dart';

void main() {
  group('DeviceBreakpoints', () {
    test('classifies width into correct device size classes', () {
      expect(DeviceBreakpoints.sizeClassForWidth(320), DeviceSizeClass.phone);
      expect(DeviceBreakpoints.sizeClassForWidth(720), DeviceSizeClass.tablet);
      expect(DeviceBreakpoints.sizeClassForWidth(1440), DeviceSizeClass.desktop);
    });

    test('provides adaptive column counts', () {
      expect(DeviceBreakpoints.columnsForWidth(375), 1);
      expect(DeviceBreakpoints.columnsForWidth(800), 2);
      expect(DeviceBreakpoints.columnsForWidth(1600), 3);
      expect(
        DeviceBreakpoints.columnsForWidth(
          1024,
          phone: 2,
          tablet: 4,
          desktop: 6,
        ),
        6,
      );
    });

    test('computes sensible default padding across breakpoints', () {
      expect(DeviceBreakpoints.horizontalPaddingForWidth(390), 16);
      expect(DeviceBreakpoints.horizontalPaddingForWidth(768), 24);
      expect(DeviceBreakpoints.horizontalPaddingForWidth(1440), 48);
    });
  });
}
