// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PomodoroSettingsAdapter extends TypeAdapter<PomodoroSettings> {
  @override
  final int typeId = 0;

  @override
  PomodoroSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSettings(
      workDuration: fields[0] as int,
      shortBreakDuration: fields[1] as int,
      longBreakDuration: fields[2] as int,
      longBreakInterval: fields[3] as int,
      autoStartBreaks: fields[4] as bool,
      autoStartPomodoros: fields[5] as bool,
      soundEnabled: fields[6] as bool,
      notificationSound: fields[7] as String,
      vibrationEnabled: fields[8] as bool,
      theme: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.workDuration)
      ..writeByte(1)
      ..write(obj.shortBreakDuration)
      ..writeByte(2)
      ..write(obj.longBreakDuration)
      ..writeByte(3)
      ..write(obj.longBreakInterval)
      ..writeByte(4)
      ..write(obj.autoStartBreaks)
      ..writeByte(5)
      ..write(obj.autoStartPomodoros)
      ..writeByte(6)
      ..write(obj.soundEnabled)
      ..writeByte(7)
      ..write(obj.notificationSound)
      ..writeByte(8)
      ..write(obj.vibrationEnabled)
      ..writeByte(9)
      ..write(obj.theme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
