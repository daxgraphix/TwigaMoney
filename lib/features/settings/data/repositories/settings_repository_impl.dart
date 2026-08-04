import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box settingsBox;

  SettingsRepositoryImpl({required this.settingsBox});

  @override
  Future<Either<Failure, bool>> getDarkMode() async {
    try {
      return Right(settingsBox.get('darkMode', defaultValue: false));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDarkMode(bool isEnabled) async {
    try {
      await settingsBox.put('darkMode', isEnabled);
      await settingsBox.put('themeMode', isEnabled ? 'dark' : 'light');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getLanguage() async {
    try {
      return Right(settingsBox.get('languageCode', defaultValue: 'en'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setLanguage(String languageCode) async {
    try {
      await settingsBox.put('languageCode', languageCode);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getCurrency() async {
    try {
      return Right(settingsBox.get('selectedCurrency', defaultValue: 'TZS'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setCurrency(String currencyCode) async {
    try {
      await settingsBox.put('selectedCurrency', currencyCode);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getDateFormat() async {
    try {
      return Right(settingsBox.get('dateFormat', defaultValue: 'dd MMM yyyy'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDateFormat(String format) async {
    try {
      await settingsBox.put('dateFormat', format);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getUserName() async {
    try {
      return Right(settingsBox.get('userName', defaultValue: ''));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserName(String name) async {
    try {
      await settingsBox.put('userName', name);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getUserEmail() async {
    try {
      return Right(settingsBox.get('userEmail', defaultValue: ''));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserEmail(String email) async {
    try {
      await settingsBox.put('userEmail', email);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getUserPhone() async {
    try {
      return Right(settingsBox.get('userPhone', defaultValue: ''));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserPhone(String phone) async {
    try {
      await settingsBox.put('userPhone', phone);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportData() async {
    try {
      final json = await HiveDatabase.exportAllData();
      return Right(json);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> importData(String jsonString) async {
    try {
      await HiveDatabase.importAllData(jsonString);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
