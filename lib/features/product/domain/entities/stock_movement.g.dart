// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockMovementAdapter extends TypeAdapter<StockMovement> {
  @override
  final int typeId = 22;

  @override
  StockMovement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockMovement(
      id: fields[0] as String,
      productId: fields[1] as String,
      type: fields[2] as MovementType,
      quantity: fields[3] as int,
      previousStock: fields[4] as int,
      newStock: fields[5] as int,
      timestamp: fields[6] as DateTime,
      reference: fields[7] as String,
      notes: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockMovement obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.previousStock)
      ..writeByte(5)
      ..write(obj.newStock)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.reference)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovementTypeAdapter extends TypeAdapter<MovementType> {
  @override
  final int typeId = 21;

  @override
  MovementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MovementType.procurement;
      case 1:
        return MovementType.sale;
      case 2:
        return MovementType.adjustment;
      case 3:
        return MovementType.returnIn;
      case 4:
        return MovementType.returnOut;
      default:
        return MovementType.procurement;
    }
  }

  @override
  void write(BinaryWriter writer, MovementType obj) {
    switch (obj) {
      case MovementType.procurement:
        writer.writeByte(0);
        break;
      case MovementType.sale:
        writer.writeByte(1);
        break;
      case MovementType.adjustment:
        writer.writeByte(2);
        break;
      case MovementType.returnIn:
        writer.writeByte(3);
        break;
      case MovementType.returnOut:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
