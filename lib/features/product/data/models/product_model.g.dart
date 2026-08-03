// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String,
      name: fields[1] as String,
      barcode: fields[2] as String,
      price: fields[3] as double,
      costPrice: fields[4] as double,
      stock: fields[5] as int,
      minStockThreshold: fields[6] as int,
      category: fields[7] as String,
      discountPercentage: fields[8] as double,
      taxPercentage: fields[9] as double,
      lastStockUpdate: fields[10] as DateTime,
      totalSold: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.costPrice)
      ..writeByte(5)
      ..write(obj.stock)
      ..writeByte(6)
      ..write(obj.minStockThreshold)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.discountPercentage)
      ..writeByte(9)
      ..write(obj.taxPercentage)
      ..writeByte(10)
      ..write(obj.lastStockUpdate)
      ..writeByte(11)
      ..write(obj.totalSold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
