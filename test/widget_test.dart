// Basic widget test for DayWatch application.

import 'package:flutter_test/flutter_test.dart';
import 'package:daywatch/main.dart';
import 'package:daywatch/widgets/daywatch_logo.dart';

void main() {
  testWidgets('App starts with SplashScreen and displays DaywatchLogo', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that SplashScreen builds and displays DaywatchLogo.
    expect(find.byType(DaywatchLogo), findsOneWidget);

    // Faire avancer le temps pour liquider le Timer delayed de 3.5s du SplashScreen
    await tester.pump(const Duration(milliseconds: 3600));
  });
}
