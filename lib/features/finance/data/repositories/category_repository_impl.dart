import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl();

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final box = HiveDatabase.categoryBox;
      final categories = box.values.toList();
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get categories: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, Category>> getCategoryById(String id) async {
     try {
       final box = HiveDatabase.categoryBox;
       final category = box.get(id);
       if (category == null) {
         return const Left(NotFoundFailure('Category not found'));
       }
       return Right(category);
     } catch (e) {
       return Left(DatabaseFailure('Failed to get category: ${e.toString()}'));
     }
   }

  @override
  Future<Either<Failure, Category>> addCategory(Category category) async {
    try {
      final box = HiveDatabase.categoryBox;
      await box.put(category.id, category);
      return Right(category);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      final box = HiveDatabase.categoryBox;
      await box.put(category.id, category);
      return Right(category);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      final box = HiveDatabase.categoryBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete category: ${e.toString()}'));
    }
  }
}