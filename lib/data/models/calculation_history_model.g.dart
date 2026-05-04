// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationHistoryModelAdapter
    extends TypeAdapter<CalculationHistoryModel> {
  @override
  final int typeId = 0;

  @override
  CalculationHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationHistoryModel(
      mode: fields[0] as String,
      inputHour: fields[1] as int,
      inputMinute: fields[2] as int,
      calculatedAt: fields[3] as DateTime,
      resultTimes: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CalculationHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.mode)
      ..writeByte(1)
      ..write(obj.inputHour)
      ..writeByte(2)
      ..write(obj.inputMinute)
      ..writeByte(3)
      ..write(obj.calculatedAt)
      ..writeByte(4)
      ..write(obj.resultTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
