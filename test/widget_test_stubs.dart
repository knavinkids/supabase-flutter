import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockWidget extends StatefulWidget {
  const MockWidget({Key? key}) : super(key: key);

  @override
  State<MockWidget> createState() => _MockWidgetState();
}

class _MockWidgetState extends State<MockWidget> {
  bool isSignedIn = true;

  @override
  Widget build(BuildContext context) {
    return isSignedIn
        ? TextButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
            },
            child: const Text('Sign out'),
          )
        : const Text('You have signed out');
  }

  @override
  void initState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        setState(() {
          isSignedIn = false;
        });
      }
    });
    super.initState();
  }
}

class MockExpiredStorage extends LocalStorage {
  MockExpiredStorage()
      : super(
          initialize: () async {},

          // Session expires at is at its maximum value for unix timestamp
          accessToken: () async =>
              '{"currentSession":{"token_type": "","access_token":"","expires_in":20,"refresh_token":"","user":{"app_metadata": {},"id":"","aud":"","created_at":"","role":"authenticated","updated_at":""}},"expiresAt":${((DateTime.now().subtract(Duration(seconds: 11))).millisecondsSinceEpoch / 1000).round()}}',
          persistSession: (_) async {},
          removePersistedSession: () async {},
          hasAccessToken: () async => true,
        );
}

class MockLocalStorage extends LocalStorage {
  MockLocalStorage()
      : super(
          initialize: () async {},

          // Session expires at is at its maximum value for unix timestamp
          accessToken: () async =>
              '{"currentSession":{"token_type": "","access_token":"","expires_in":3600,"refresh_token":"","user":{"app_metadata": {},"id":"","aud":"","created_at":"","role":"authenticated","updated_at":""}},"expiresAt":2147483647}',
          persistSession: (_) async {},
          removePersistedSession: () async {},
          hasAccessToken: () async => true,
        );
}

/// Registers the mock handler for uni_links
void mockAppLink() {
  const channel = MethodChannel('com.llfbandit.app_links/messages');
  const anotherChannel = MethodChannel('com.llfbandit.app_links/events');

  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) => null);

  TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
      .setMockMethodCallHandler(anotherChannel, (message) => null);
}
