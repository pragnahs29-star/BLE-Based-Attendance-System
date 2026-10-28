import 'package:flutter_test/flutter_test.dart';
import 'package:verification_test/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentPhotoTestApp());

    expect(find.byType(StudentPhotoTestApp), findsOneWidget);
  });
}