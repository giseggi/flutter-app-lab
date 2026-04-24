import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_test/app/app.dart';

void main() {
  testWidgets('TODO 화면이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('Task Board'), findsOneWidget);
    expect(find.text('할 일을 입력하세요'), findsOneWidget);
  });
}
