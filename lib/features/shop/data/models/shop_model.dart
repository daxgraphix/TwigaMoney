import 'package:hive/hive.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String id; // ignore: overridden_fields

  @override
  @HiveField(1)
  final String name; // ignore: overridden_fields

  @override
  @HiveField(2)
  final String addressLine1; // ignore: overridden_fields

  @override
  @HiveField(3)
  final String addressLine2; // ignore: overridden_fields

  @override
  @HiveField(4)
  final String phoneNumber; // ignore: overridden_fields

  @override
  @HiveField(5)
  final String footerText; // ignore: overridden_fields

  @override
  @HiveField(6)
  final String upiId; // ignore: overridden_fields

  @override
  @HiveField(7)
  final String logoText; // ignore: overridden_fields

  const ShopModel({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.footerText,
    required this.upiId,
    this.logoText = '',
  }) : super(
          id: id,
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          footerText: footerText,
          upiId: upiId,
          logoText: logoText,
        );

  factory ShopModel.fromEntity(Shop shop) {
    if (shop is ShopModel) {
      return shop;
    }
    return ShopModel(
      id: shop.id,
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      footerText: shop.footerText,
      upiId: shop.upiId,
      logoText: shop.logoText,
    );
  }

  Shop toEntity() {
    return Shop(
      id: id,
      name: name,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      phoneNumber: phoneNumber,
      footerText: footerText,
      upiId: upiId,
      logoText: logoText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'phoneNumber': phoneNumber,
      'footerText': footerText,
      'upiId': upiId,
      'logoText': logoText,
    };
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      phoneNumber: json['phoneNumber'] as String,
      footerText: json['footerText'] as String,
      upiId: json['upiId'] as String,
      logoText: json['logoText'] as String? ?? '',
    );
  }
}
