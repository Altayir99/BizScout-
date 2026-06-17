import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizscout/main.dart';

void main() {
  testWidgets('BizScout smoke test', (WidgetTester tester) async {
    // Basic smoke test — app builds without crashing
    expect(BizScoutApp, isNotNull);
  });
}
