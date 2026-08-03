// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopModelAdapter extends TypeAdapter<ShopModel> {
  @override
  final int typeId = 1;

  @override
  ShopModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopModel(
      id: fields[0] as String,
      name: fields[1] as String,
      addressLine1: fields[2] as String,
      addressLine2: fields[3] as String,
      phoneNumber: fields[4] as String,
      footerText: fields[5] as String,
      upiId: fields[6] as String,
      logoText: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShopModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.addressLine1)
      ..writeByte(3)
      ..write(obj.addressLine2)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.footerText)
      ..writeByte(6)
      ..write(obj.upiId)
      ..writeByte(7)
      ..write(obj.logoText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
