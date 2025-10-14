import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorageAdapter {

  static final instance = SecureStorageAdapter._();
  SecureStorageAdapter._();


  final _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    final encryptionKey = await _secureStorage.read(key: 'encryption_key');
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: 'encryption_key',
        value: base64UrlEncode(key),
      );
    }
  }

  Future<String> getKey() async {
    final key = await _secureStorage.read(key: 'encryption_key');
    return key ?? "";
  }
}