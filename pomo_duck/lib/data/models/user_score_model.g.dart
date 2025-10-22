// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserScoreModelAdapter extends TypeAdapter<UserScoreModel> {
  @override
  final int typeId = 10;

  @override
  UserScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserScoreModel(
      totalPoints: fields[0] as int,
      currentStreak: fields[1] as int,
      longestStreak: fields[2] as int,
      lastTaskCompletedDate: fields[3] as DateTime,
      tasksCompletedToday: fields[4] as int,
      totalTasksCompleted: fields[5] as int,
      bonusPointsEarned: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserScoreModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalPoints)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.longestStreak)
      ..writeByte(3)
      ..write(obj.lastTaskCompletedDate)
      ..writeByte(4)
      ..write(obj.tasksCompletedToday)
      ..writeByte(5)
      ..write(obj.totalTasksCompleted)
      ..writeByte(6)
      ..write(obj.bonusPointsEarned)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
