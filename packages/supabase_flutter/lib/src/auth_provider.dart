// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:supabase_flutter/supabase_flutter.dart';

/// A base class which all providers must extend.
abstract class AuthProvider {
  /// Constructs a new instance with a given provider identifier.
  AuthProvider(this.provider);

  /// The provider ID.
  final Provider provider;

  @override
  String toString() {
    return 'AuthProvider(provider: ${provider.name})';
  }
}
