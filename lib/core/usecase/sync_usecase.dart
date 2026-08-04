import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';
import '../repository/sync_repository.dart';
import 'usecase.dart';

class SyncAllUseCase implements UseCase<void, NoParams> {
  final SyncRepository repository;

  SyncAllUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncAll();
  }
}

class PushChangesUseCase implements UseCase<void, NoParams> {
  final SyncRepository repository;

  PushChangesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.pushChanges();
  }
}

class PullChangesUseCase implements UseCase<void, NoParams> {
  final SyncRepository repository;

  PullChangesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.pullChanges();
  }
}
