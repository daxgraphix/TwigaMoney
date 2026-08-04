import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../settings/domain/repositories/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsCubit({required this.settingsRepository}) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final darkMode = await settingsRepository.getDarkMode();
    final language = await settingsRepository.getLanguage();
    final currency = await settingsRepository.getCurrency();
    final dateFormat = await settingsRepository.getDateFormat();
    final userName = await settingsRepository.getUserName();
    final userEmail = await settingsRepository.getUserEmail();
    final userPhone = await settingsRepository.getUserPhone();

    emit(state.copyWith(
      isDarkMode: darkMode.getOrElse((_) => false),
      languageCode: language.getOrElse((_) => 'en'),
      currencyCode: currency.getOrElse((_) => 'TZS'),
      dateFormat: dateFormat.getOrElse((_) => 'dd MMM yyyy'),
      userName: userName.getOrElse((_) => ''),
      userEmail: userEmail.getOrElse((_) => ''),
      userPhone: userPhone.getOrElse((_) => ''),
      status: SettingsStatus.loaded,
    ));
  }

  Future<void> toggleDarkMode(bool isEnabled) async {
    final result = await settingsRepository.setDarkMode(isEnabled);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(isDarkMode: isEnabled)),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final result = await settingsRepository.setLanguage(languageCode);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(languageCode: languageCode)),
    );
  }

  Future<void> setCurrency(String currencyCode) async {
    final result = await settingsRepository.setCurrency(currencyCode);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(currencyCode: currencyCode)),
    );
  }

  Future<void> setDateFormat(String format) async {
    final result = await settingsRepository.setDateFormat(format);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(dateFormat: format)),
    );
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    if (name != null) await settingsRepository.setUserName(name);
    if (email != null) await settingsRepository.setUserEmail(email);
    if (phone != null) await settingsRepository.setUserPhone(phone);
    
    emit(state.copyWith(
      userName: name ?? state.userName,
      userEmail: email ?? state.userEmail,
      userPhone: phone ?? state.userPhone,
    ));
  }

  Future<void> clearCache() async {
    await settingsRepository.clearCache();
  }
}
