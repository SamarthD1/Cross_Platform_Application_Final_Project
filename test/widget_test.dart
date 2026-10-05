import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_kitchen_platform/main.dart';

void main() {
  testWidgets('CloudKitchen platform auth & login smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CloudKitchenApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify login screen renders with title and role-based test pills
    expect(find.text('CloudKitchen OS'), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
    expect(find.text('Customer'), findsWidgets);
    expect(find.text('Kitchen (Vendor)'), findsWidgets);
    expect(find.text('Delivery Partner'), findsWidgets);
    expect(find.text('Platform Admin'), findsWidgets);

    // Tap the 'Sign In to Dashboard' button to test Customer login
    await tester.tap(find.text('Sign In to Dashboard'));
    await tester.pumpAndSettle();

    // Verifies GoRouter successfully redirected to /customer
    expect(find.text('Swiggy One'), findsWidgets);
    expect(find.text('Live Orders Kanban'), findsNothing);
  });
}
