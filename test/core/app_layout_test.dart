import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_route/core/app_layout.dart';
import 'package:safe_route/core/app_styles.dart';

void main() {
  Future<void> pumpLayout(
    WidgetTester tester, {
    required Size size,
    required AppLayoutWidth width,
    required Key key,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppLayout(
            width: width,
            child: SizedBox(key: key, width: double.infinity, height: 80),
          ),
        ),
      ),
    );
  }

  testWidgets('AppLayout uses available width on narrow screens', (
    tester,
  ) async {
    const contentKey = Key('mobile-content');

    await pumpLayout(
      tester,
      size: const Size(390, 844),
      width: AppLayoutWidth.form,
      key: contentKey,
    );

    final contentSize = tester.getSize(find.byKey(contentKey));

    expect(contentSize.width, 390 - (AppStyles.pagePaddingCompact * 2));
  });

  testWidgets('AppLayout caps width on large screens', (tester) async {
    const contentKey = Key('desktop-content');

    await pumpLayout(
      tester,
      size: const Size(1280, 900),
      width: AppLayoutWidth.list,
      key: contentKey,
    );

    final contentSize = tester.getSize(find.byKey(contentKey));

    expect(contentSize.width, AppStyles.listMaxWidthWide);
  });
}
