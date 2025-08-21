// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:encryptiview/main.dart'; // Make sure this import points to your main.dart

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // This will test if the initial screen of your app can be built without errors.
    await tester.pumpWidget(const EncryptiViewApp());

    // You can add more specific tests here later,
    // for now, just building the app is a good basic test.
    expect(find.byType(EncryptiViewApp), findsOneWidget);
  });
}
