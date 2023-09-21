import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'widget_test_stubs.dart';

void main() {
  const supabaseUrl = '';
  const supabaseKey = '';

  setUpAll(() async {
    mockAppLink();
  });

  testWidgets('Signing out triggers AuthChangeEvent.signedOut event',
      (tester) async {
    // Initialize the Supabase singleton
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      goTrueOptions: FlutterGoTrueClientOptions(
        localStorage: MockLocalStorage(),
        pkceAsyncStorage: MockAsyncStorage(),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: MockWidget()));
    await tester.tap(find.text('Sign out'));
    await tester.pump();
    expect(find.text('You have signed out'), findsOneWidget);
  });

  test(
    "Migrates from Hive to SharedPreferences",
    () async {
      final hiveLocalStorage = TestHiveLocalStorage();
      await hiveLocalStorage.initialize();
      await hiveLocalStorage.persistSession('test');
      final boxFile =
          File("${path.current}/auth_test/supabase_authentication.hive");
      expect(await boxFile.exists(), true);

      final migrationLocalStorage = TestMigrationLocalStorage();
      await migrationLocalStorage.initialize();
      expect(await boxFile.exists(), false);
      expect(await migrationLocalStorage.accessToken(), "test");
      expect(await boxFile.parent.exists(), false);
    },
  );
}
