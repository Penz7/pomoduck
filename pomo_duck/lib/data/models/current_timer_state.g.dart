// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_timer_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentTimerStateAdapter extends TypeAdapter<CurrentTimerState> {
  @override
  final int typeId = 2;

  @override
  CurrentTimerState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentTimerState(
      isRunning: fields[0] as bool,
      sessionType: fields[1] as String,
      taskId: fields[2] as int?,
      plannedDurationSeconds: fields[3] as int,
      elapsedSeconds: fields[4] as int,
      startTime: fields[5] as DateTime?,
      completedPomodoros: fields[6] as int,
      pauseTime: fields[7] as DateTime?,
      sessionId: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentTimerState obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isRunning)
      ..writeByte(1)
      ..write(obj.sessionType)
      ..writeByte(2)
      ..write(obj.taskId)
      ..writeByte(3)
      ..write(obj.plannedDurationSeconds)
      ..writeByte(4)
      ..write(obj.elapsedSeconds)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.completedPomodoros)
      ..writeByte(7)
      ..write(obj.pauseTime)
      ..writeByte(8)
      ..write(obj.sessionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentTimerStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
