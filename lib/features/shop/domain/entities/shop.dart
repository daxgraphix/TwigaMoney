import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String footerText;
  final String upiId;
  final String logoText;

  const Shop({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.footerText,
    required this.upiId,
    this.logoText = '',
  });

  @override
  List<Object?> get props =>
      [id, name, addressLine1, addressLine2, phoneNumber, footerText, upiId, logoText];

  Shop copyWith({
    String? id,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? footerText,
    String? upiId,
    String? logoText,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      footerText: footerText ?? this.footerText,
      upiId: upiId ?? this.upiId,
      logoText: logoText ?? this.logoText,
    );
  }
}