import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';
import '../data/sync_status.dart';
import '../data/hive_database.dart';
import 'sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  @override
  Future<Either<Failure, void>> pushChanges() async {
    try {
      // 1. Get all pending items across all relevant boxes
      final pendingProducts = HiveDatabase.productBox.values
          .where((p) => p.syncStatus == SyncStatus.pending || p.syncStatus == SyncStatus.failed)
          .toList();
      
      final pendingTransactions = HiveDatabase.transactionBox.values
          .where((t) => t.syncStatus == SyncStatus.pending || t.syncStatus == SyncStatus.failed)
          .toList();

      final pendingSales = HiveDatabase.salesTransactionBox.values
          .where((s) => s.syncStatus == SyncStatus.pending || s.syncStatus == SyncStatus.failed)
          .toList();

      // 2. Mock Remote Push (In a real app, this would be an API call)
      // For now, we simulate success and update local status to 'synced'
      
      for (var product in pendingProducts) {
        // Simulate API call: await apiClient.pushProduct(product.toJson());
        await HiveDatabase.productBox.put(
          product.id,
          product.copyWith(syncStatus: SyncStatus.synced, updatedAt: DateTime.now()),
        );
      }

      for (var tx in pendingTransactions) {
        await HiveDatabase.transactionBox.put(
          tx.id,
          tx.copyWith(syncStatus: SyncStatus.synced, updatedAt: DateTime.now()),
        );
      }

      for (var sale in pendingSales) {
        await HiveDatabase.salesTransactionBox.put(
          sale.id,
          sale.copyWith(syncStatus: SyncStatus.synced, updatedAt: DateTime.now()),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Push failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pullChanges() async {
    try {
      // Mock Remote Pull
      // In a real app: final remoteData = await apiClient.getChanges(lastSyncTimestamp);
      // Then merge remoteData into Hive boxes.
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Pull failed: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      int count = 0;
      count += HiveDatabase.productBox.values.where((p) => p.syncStatus != SyncStatus.synced).length;
      count += HiveDatabase.transactionBox.values.where((t) => t.syncStatus != SyncStatus.synced).length;
      count += HiveDatabase.salesTransactionBox.values.where((s) => s.syncStatus != SyncStatus.synced).length;
      count += HiveDatabase.customerBox.values.where((c) => c.syncStatus != SyncStatus.synced).length;
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get pending count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsPending(String entityType, String id) async {
    try {
      // This is usually handled automatically when saving an entity,
      // but this method allows manual marking.
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark as pending: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> retryFailedSync() async {
    return pushChanges();
  }

  @override
  Future<Either<Failure, void>> syncAll() async {
    final pullResult = await pullChanges();
    if (pullResult.isLeft()) return pullResult;
    return pushChanges();
  }
}
