import 'dart:convert';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';

ZeroWasteOffer zeroWasteOfferFromJson(String str) =>
    ZeroWasteOffer.fromJson(json.decode(str));

String zeroWasteOfferToJson(ZeroWasteOffer data) =>
    json.encode(data.toJson());

class ZeroWasteOffer {
  ZeroWasteOffer({
    required this.id,
    required this.vendorId,
    this.productId,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.availableQuantity,
    required this.pickupTimeStart,
    required this.pickupTimeEnd,
    required this.expiresAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.photo,
    this.product,
    this.vendor,
  });

  int id;
  int vendorId;
  int? productId;
  String name;
  String description;
  double originalPrice;
  double discountedPrice;
  int availableQuantity;
  String pickupTimeStart;
  String pickupTimeEnd;
  String expiresAt;
  int isActive;
  String createdAt;
  String updatedAt;
  String? photo;
  Product? product;
  Vendor? vendor;

  factory ZeroWasteOffer.fromJson(Map<String, dynamic> json) {
    return ZeroWasteOffer(
      id: json["id"] ?? 0,
      vendorId: json["vendor_id"] is int
          ? json["vendor_id"]
          : int.tryParse(json["vendor_id"]?.toString() ?? "0") ?? 0,
      productId: json["product_id"] != null
          ? (json["product_id"] is int
              ? json["product_id"]
              : int.tryParse(json["product_id"]?.toString() ?? ""))
          : null,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      originalPrice: json["original_price"] != null
          ? double.parse(json["original_price"].toString())
          : 0.0,
      discountedPrice: json["discounted_price"] != null
          ? double.parse(json["discounted_price"].toString())
          : 0.0,
      availableQuantity: json["available_quantity"] is int
          ? json["available_quantity"]
          : int.tryParse(json["available_quantity"]?.toString() ?? "0") ?? 0,
      pickupTimeStart: json["pickup_time_start"] ?? "",
      pickupTimeEnd: json["pickup_time_end"] ?? "",
      expiresAt: json["expires_at"] ?? "",
      isActive: json["is_active"] is int
          ? json["is_active"]
          : int.tryParse(json["is_active"]?.toString() ?? "1") ?? 1,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      photo: json["photo"],
      product:
          json["product"] != null ? Product.fromJson(json["product"]) : null,
      vendor: json["vendor"] != null ? Vendor.fromJson(json["vendor"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_id": vendorId,
        "product_id": productId,
        "name": name,
        "description": description,
        "original_price": originalPrice,
        "discounted_price": discountedPrice,
        "available_quantity": availableQuantity,
        "pickup_time_start": pickupTimeStart,
        "pickup_time_end": pickupTimeEnd,
        "expires_at": expiresAt,
        "is_active": isActive,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "photo": photo,
        "product": product?.toJson(),
        "vendor": vendor?.toJson(),
      };

  // Getters
  double get discountPercentage {
    if (originalPrice > 0) {
      return ((originalPrice - discountedPrice) / originalPrice) * 100;
    }
    return 0;
  }

  bool get isExpired {
    try {
      final expiryDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  bool get isAvailable {
    return isActive == 1 && !isExpired && availableQuantity > 0;
  }
}

