import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/api_client.dart';

void main() {
  testWidgets('shows SmartAgri authentication screen', (tester) async {
    final apiClient = ApiClient();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiClient>.value(value: apiClient),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(apiClient),
          ),
        ],
        child: const LoginScreen(),
      ),
    );

    expect(find.text('SmartAgri'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('New farmer? Create an account'), findsOneWidget);
  });
}
