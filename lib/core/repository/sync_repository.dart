import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';

abstract class SyncRepository {
  /// Pushes all pending local changes to the remote server.
  Future<Either<Failure, void>> pushChanges();

  /// Pulls all remote changes since the last sync.
  Future<Either<Failure, void>> pullChanges();

  /// Gets the count of pending changes across all entities.
  Future<Either<Failure, int>> getPendingCount();

  /// Marks a specific entity as pending sync.
  Future<Either<Failure, void>> markAsPending(String entityType, String id);

  /// Clears sync errors and attempts to retry.
  Future<Either<Failure, void>> retryFailedSync();
  
  /// Performs a full synchronization (pull then push).
  Future<Either<Failure, void>> syncAll();
}
