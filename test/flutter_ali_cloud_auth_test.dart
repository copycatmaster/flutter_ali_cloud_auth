import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ali_cloud_auth/flutter_ali_cloud_auth.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_ali_cloud_auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await FlutterAliCloudAuth.platformVersion, '42');
  });
}
