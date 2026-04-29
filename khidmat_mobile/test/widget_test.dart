import 'package:flutter_test/flutter_test.dart';
import 'package:khidmat_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen on startup', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KhidmatApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Patient Records Management'), findsOneWidget);
  });
}
