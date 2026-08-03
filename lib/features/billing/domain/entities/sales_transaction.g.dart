// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesTransactionAdapter extends TypeAdapter<SalesTransaction> {
  @override
  final int typeId = 20;

  @override
  SalesTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesTransaction(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      sellingPrice: fields[3] as double,
      costPrice: fields[4] as double,
      quantity: fields[5] as int,
      timestamp: fields[10] as DateTime,
      shiftId: fields[11] as String,
      customerId: fields[12] as String,
      status: fields[13] as TransactionStatus,
      items: (fields[14] as List).cast<String>(),
      createdAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SalesTransaction obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.sellingPrice)
      ..writeByte(4)
      ..write(obj.costPrice)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.totalRevenue)
      ..writeByte(7)
      ..write(obj.totalCost)
      ..writeByte(8)
      ..write(obj.totalProfit)
      ..writeByte(9)
      ..write(obj.marginPercentage)
      ..writeByte(10)
      ..write(obj.timestamp)
      ..writeByte(11)
      ..write(obj.shiftId)
      ..writeByte(12)
      ..write(obj.customerId)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.items)
      ..writeByte(15)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
