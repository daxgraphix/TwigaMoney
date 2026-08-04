import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> setDarkMode(bool isEnabled);
  Future<Either<Failure, bool>> getDarkMode();
  
  Future<Either<Failure, void>> setLanguage(String languageCode);
  Future<Either<Failure, String>> getLanguage();
  
  Future<Either<Failure, void>> setCurrency(String currencyCode);
  Future<Either<Failure, String>> getCurrency();
  
  Future<Either<Failure, void>> setDateFormat(String format);
  Future<Either<Failure, String>> getDateFormat();

  Future<Either<Failure, void>> setUserName(String name);
  Future<Either<Failure, String>> getUserName();

  Future<Either<Failure, void>> setUserEmail(String email);
  Future<Either<Failure, String>> getUserEmail();

  Future<Either<Failure, void>> setUserPhone(String phone);
  Future<Either<Failure, String>> getUserPhone();

  Future<Either<Failure, String>> exportData();
  Future<Either<Failure, void>> importData(String jsonString);
  Future<Either<Failure, void>> clearCache();
}
