// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CircuitAdapter extends TypeAdapter<Circuit> {
  @override
  final int typeId = 1;

  @override
  Circuit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Circuit(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      timezone: fields[3] as String,
      flagEmoji: fields[4] as String,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      currency: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Circuit obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.timezone)
      ..writeByte(4)
      ..write(obj.flagEmoji)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
