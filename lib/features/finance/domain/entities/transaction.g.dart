// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 12;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      description: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      categoryId: fields[4] as String,
      accountId: fields[5] as String,
      type: fields[6] as TransactionType,
      isRecurring: fields[7] as bool,
      recurringInterval: fields[8] as RecurringInterval?,
      fromAccountId: fields[9] as String?,
      toAccountId: fields[10] as String?,
      productId: fields[11] as String?,
      stockQuantity: fields[12] as int?,
      syncStatus: fields[13] as SyncStatus,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.accountId)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.isRecurring)
      ..writeByte(8)
      ..write(obj.recurringInterval)
      ..writeByte(9)
      ..write(obj.fromAccountId)
      ..writeByte(10)
      ..write(obj.toAccountId)
      ..writeByte(11)
      ..write(obj.productId)
      ..writeByte(12)
      ..write(obj.stockQuantity)
      ..writeByte(13)
      ..write(obj.syncStatus)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 10;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.expense;
      case 1:
        return TransactionType.income;
      case 2:
        return TransactionType.stock;
      case 3:
        return TransactionType.fundTransfer;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.expense:
        writer.writeByte(0);
        break;
      case TransactionType.income:
        writer.writeByte(1);
        break;
      case TransactionType.stock:
        writer.writeByte(2);
        break;
      case TransactionType.fundTransfer:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringIntervalAdapter extends TypeAdapter<RecurringInterval> {
  @override
  final int typeId = 11;

  @override
  RecurringInterval read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringInterval.daily;
      case 1:
        return RecurringInterval.weekly;
      case 2:
        return RecurringInterval.monthly;
      case 3:
        return RecurringInterval.yearly;
      default:
        return RecurringInterval.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringInterval obj) {
    switch (obj) {
      case RecurringInterval.daily:
        writer.writeByte(0);
        break;
      case RecurringInterval.weekly:
        writer.writeByte(1);
        break;
      case RecurringInterval.monthly:
        writer.writeByte(2);
        break;
      case RecurringInterval.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringIntervalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
