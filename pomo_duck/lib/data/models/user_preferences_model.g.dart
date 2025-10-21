// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 1;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      language: fields[0] as String,
      dateFormat: fields[1] as String,
      timeFormat: fields[2] as String,
      showNotifications: fields[3] as bool,
      showTaskProgress: fields[4] as bool,
      showDailyStats: fields[5] as bool,
      showPomodoroCounter: fields[6] as bool,
      showSessionProgress: fields[7] as bool,
      defaultTaskCategory: fields[8] as String,
      enableDarkMode: fields[9] as bool,
      enableHapticFeedback: fields[10] as bool,
      appTheme: fields[11] as String,
      enableNotificationSound: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.dateFormat)
      ..writeByte(2)
      ..write(obj.timeFormat)
      ..writeByte(3)
      ..write(obj.showNotifications)
      ..writeByte(4)
      ..write(obj.showTaskProgress)
      ..writeByte(5)
      ..write(obj.showDailyStats)
      ..writeByte(6)
      ..write(obj.showPomodoroCounter)
      ..writeByte(7)
      ..write(obj.showSessionProgress)
      ..writeByte(8)
      ..write(obj.defaultTaskCategory)
      ..writeByte(9)
      ..write(obj.enableDarkMode)
      ..writeByte(10)
      ..write(obj.enableHapticFeedback)
      ..writeByte(11)
      ..write(obj.appTheme)
      ..writeByte(12)
      ..write(obj.enableNotificationSound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
