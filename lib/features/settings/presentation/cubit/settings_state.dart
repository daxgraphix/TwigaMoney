part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final String currencyCode;
  final String dateFormat;
  final String userName;
  final String userEmail;
  final String userPhone;
  final SettingsStatus status;
  final String? errorMessage;

  const SettingsState({
    this.isDarkMode = false,
    this.languageCode = 'en',
    this.currencyCode = 'TZS',
    this.dateFormat = 'dd MMM yyyy',
    this.userName = '',
    this.userEmail = '',
    this.userPhone = '',
    this.status = SettingsStatus.initial,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    String? currencyCode,
    String? dateFormat,
    String? userName,
    String? userEmail,
    String? userPhone,
    SettingsStatus? status,
    String? errorMessage,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      dateFormat: dateFormat ?? this.dateFormat,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        languageCode,
        currencyCode,
        dateFormat,
        userName,
        userEmail,
        userPhone,
        status,
        errorMessage,
      ];
}
