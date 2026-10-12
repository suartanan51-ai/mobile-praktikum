
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/main.dart';

void main() {
  testWidgets('Aplikasi dapat ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const CourseExplorerApp());

    await tester.pumpAndSettle();

    expect(find.text('Eksperimen ValueNotifier'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
  });
}
