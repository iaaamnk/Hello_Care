import 'package:flutter_test/flutter_test.dart';
import 'package:hello_care/main.dart';

void main() {
  testWidgets('HelloCare App launches on Role Selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloCareApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to HelloCare'), findsOneWidget);
    expect(find.text('Patient Portal'), findsOneWidget);
    expect(find.text('Doctor Portal'), findsOneWidget);
  });
}
