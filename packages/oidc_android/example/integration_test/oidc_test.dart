import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oidc_platform_interface/oidc_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('getPlatformName returns Android', (WidgetTester _) async {
    final OidcPlatform platform = OidcPlatform.instance;
    await expectLater(platform.getPlatformName(), completion('Android'));
  });
}