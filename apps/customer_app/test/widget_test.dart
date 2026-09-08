import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:customer_app/main.dart';

void main() {
  testWidgets('Madadgaar customer app boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MadadgaarCustomerApp()));
    await tester.pump();
    expect(find.text('Madadgaar'), findsWidgets);
  });
}
