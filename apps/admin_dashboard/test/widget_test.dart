import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:admin_dashboard/main.dart';

void main() {
  testWidgets('Madadgaar admin app boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MadadgaarAdminApp()));
    await tester.pump();
    expect(find.text('Madadgaar Admin'), findsWidgets);
  });
}
