import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:pomo_duck/core/local_storage/hive_data_manager.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late final AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer.setAsset('assets/sounds/quack.mp3');
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo AudioService: $e');
      }
    }
  }

  Future<void> playQuack() async {
    final prefs = HiveDataManager.getUserPreferences();
    if (!prefs.enableNotificationSound) {
      if (kDebugMode) {
        print('Âm thanh thông báo đã bị tắt trong settings');
      }
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi phát âm thanh: $e');
      }
    }
  }

  Future<void> stop() async {
    if (_isInitialized) {
      try {
        await _audioPlayer.stop();
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi dừng âm thanh: $e');
        }
      }
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _audioPlayer.dispose();
        _isInitialized = false;
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi dispose AudioService: $e');
        }
      }
    }
  }

  bool get isInitialized => _isInitialized;
}
