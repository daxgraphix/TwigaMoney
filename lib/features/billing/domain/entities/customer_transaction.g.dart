// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerTransactionAdapter extends TypeAdapter<CustomerTransaction> {
  @override
  final int typeId = 25;

  @override
  CustomerTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerTransaction(
      id: fields[0] as String,
      customerId: fields[1] as String,
      type: fields[2] as CustomerTransactionType,
      amount: fields[3] as double,
      previousBalance: fields[4] as double,
      newBalance: fields[5] as double,
      timestamp: fields[6] as DateTime,
      reference: fields[7] as String,
      notes: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerTransaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.previousBalance)
      ..writeByte(5)
      ..write(obj.newBalance)
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
      other is CustomerTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerTransactionTypeAdapter
    extends TypeAdapter<CustomerTransactionType> {
  @override
  final int typeId = 24;

  @override
  CustomerTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CustomerTransactionType.creditSale;
      case 1:
        return CustomerTransactionType.payment;
      case 2:
        return CustomerTransactionType.adjustment;
      case 3:
        return CustomerTransactionType.writeOff;
      default:
        return CustomerTransactionType.creditSale;
    }
  }

  @override
  void write(BinaryWriter writer, CustomerTransactionType obj) {
    switch (obj) {
      case CustomerTransactionType.creditSale:
        writer.writeByte(0);
        break;
      case CustomerTransactionType.payment:
        writer.writeByte(1);
        break;
      case CustomerTransactionType.adjustment:
        writer.writeByte(2);
        break;
      case CustomerTransactionType.writeOff:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
