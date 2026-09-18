import 'package:flutter_test/flutter_test.dart';
import 'package:community/main.dart';
import 'package:community/features/splash/splash_screen.dart';

void main() {
  testWidgets('CommunityHubApp smoke test loads SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const CommunityHubApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
