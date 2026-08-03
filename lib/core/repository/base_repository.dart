import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';

abstract class BaseRepository<T, ID> {
  Future<Either<Failure, List<T>>> getAll();
  Future<Either<Failure, T>> getById(ID id);
  Future<Either<Failure, T>> create(T entity);
  Future<Either<Failure, T>> update(T entity);
  Future<Either<Failure, void>> delete(ID id);
  Future<Either<Failure, List<T>>> search(String query);
}

abstract class PaginatedRepository<T, ID> extends BaseRepository<T, ID> {
  Future<Either<Failure, PaginatedResult<T>>> getPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
    Map<String, dynamic>? filters,
  });
}

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  bool get hasMore => (currentPage * pageSize) < totalCount;
  int get totalPages => (totalCount / pageSize).ceil();
}
