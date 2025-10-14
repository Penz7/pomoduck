import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_adapter.dart';
import 'local_storage_hive_key.dart';
import 'secure_storage.dart';

class LocalStorageManager {
  static final LocalStorageManager instance = LocalStorageManager._();

  LocalStorageManager._();

  final HiveAdapter _hive = HiveAdapter.instance;
  final SecureStorageAdapter _secureStorage = SecureStorageAdapter.instance;

  BoxBase getBox(String boxKey) {
    if (boxKey == HiveBoxKey.instance.userBox) {
      return _hive.secretBox;
    }
    if (boxKey == HiveBoxKey.instance.cartBox) {
      return _hive.cartBox;
    }
    return _hive.dataBox;
  }

  ValueListenable get cartBoxListener {
    return _hive.cartBox.listenable();
  }

  ValueListenable get userBoxListener {
    return _hive.secretBox.listenable();
  }

  Future<void> init() async {
    await _hive.init();
    await _secureStorage.init();
    await _hive.openBox();
  }

  Future<void> saveData<T>(
      T data, {
        required String key,
        String boxKey = 'data_box',
      }) async {
    await _hive.saveData(
      data,
      key: key,
      boxKey: boxKey,
    );
  }

  Future<void> saveDataAsList<T>(
      T data, {
        required String key,
        String boxKey = 'data_box',
      }) async {
    await _hive.saveDataAsList(
      data,
      key: key,
      boxKey: boxKey,
    );
  }

  Future<dynamic> getData(
      String key, {
        String boxKey = 'data_box',
      }) async {
    return await _hive.getData(
      key,
      boxKey: boxKey,
    );
  }

  Future<dynamic> removeDataWithKey(
      String key, {
        String boxKey = 'data_box',
      }) async {
    final box = getBox(boxKey);
    await box.delete(key);
  }

  Future<void> removeData() async {
    await _hive.removeDataBox();
  }

  Future<bool> checkLogin() async {
    final data = await getData(
      LocalStorageHiveKey.token,
      boxKey: HiveBoxKey.instance.userBox,
    );
    return data != null;
  }

  Future<void> removeLoginInfo() async {
    await _hive.removeSecretBox();
  }
}
