import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/global_widgets/custom_button.dart';

import '../helpers/test_env.dart';

void main() {
  setUpAll(initTestAppConfig);

  Future<void> pumpButton(WidgetTester tester, String title, double width) =>
      tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: CustomButton(title: title, onPressed: () {}),
              ),
            ),
          ),
        ),
      );

  /// Width the title takes on screen.
  double shownWidth(WidgetTester tester, String title) =>
      tester.getRect(find.text(title)).width;

  testWidgets('a long house name fits the onboarding button (no overflow)', (
    tester,
  ) async {
    // SM A075F: 360 dp wide, onboarding button = 60 % = 216 dp.
    const title = 'Start with T.K. Shares & Securities Ltd';
    await pumpButton(tester, title, 216);

    expect(tester.takeException(), isNull);
    expect(shownWidth(tester, title), lessThanOrEqualTo(216));
  });

  testWidgets('a title that fits keeps its size (other buttons unchanged)', (
    tester,
  ) async {
    // Test font: every letter is as wide as the font size, so use a title
    // that surely fits.
    const title = 'Login';
    await pumpButton(tester, title, 216);
    final inButton = shownWidth(tester, title);

    await pumpButton(tester, title, 1000); // room to spare: natural size
    expect(tester.takeException(), isNull);
    expect(inButton, shownWidth(tester, title));
  });
}
