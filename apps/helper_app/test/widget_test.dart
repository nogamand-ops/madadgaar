import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helper_app/main.dart';

void main() {
  testWidgets('Madadgaar helper app boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MadadgaarHelperApp()));
    await tester.pump();
    expect(find.text('Madadgaar\nfor Helpers'), findsWidgets);
  });
}
