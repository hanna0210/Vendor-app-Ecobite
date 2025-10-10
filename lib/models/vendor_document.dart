// To parse this JSON data, do
//
//     final vendorDocument = vendorDocumentFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

VendorDocument vendorDocumentFromJson(String str) =>
    VendorDocument.fromJson(json.decode(str));

String vendorDocumentToJson(VendorDocument data) =>
    json.encode(data.toJson());

class VendorDocument {
  VendorDocument({
    this.id,
    required this.documentType,
    this.documentNumber,
    this.expiryDate,
    this.issuedDate,
    this.issuingAuthority,
    this.filePath,
    this.file,
    this.isVerified = false,
    this.verificationStatus = DocumentVerificationStatus.pending,
    this.rejectionReason,
  });

  int? id;
  VendorDocumentType documentType;
  String? documentNumber;
  DateTime? expiryDate;
  DateTime? issuedDate;
  String? issuingAuthority;
  String? filePath;
  File? file; // For local file upload
  bool isVerified;
  DocumentVerificationStatus verificationStatus;
  String? rejectionReason;

  factory VendorDocument.fromJson(Map<String, dynamic> json) {
    return VendorDocument(
      id: json["id"],
      documentType: _parseDocumentType(json["document_type"]),
      documentNumber: json["document_number"],
      expiryDate: json["expiry_date"] != null
          ? DateTime.parse(json["expiry_date"])
          : null,
      issuedDate: json["issued_date"] != null
          ? DateTime.parse(json["issued_date"])
          : null,
      issuingAuthority: json["issuing_authority"],
      filePath: json["file_path"],
      isVerified: json["is_verified"] ?? false,
      verificationStatus:
          _parseVerificationStatus(json["verification_status"]),
      rejectionReason: json["rejection_reason"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "document_type": documentType.value,
        "document_number": documentNumber,
        "expiry_date": expiryDate?.toIso8601String(),
        "issued_date": issuedDate?.toIso8601String(),
        "issuing_authority": issuingAuthority,
        "file_path": filePath,
        "is_verified": isVerified,
        "verification_status": verificationStatus.value,
        "rejection_reason": rejectionReason,
      };

  static VendorDocumentType _parseDocumentType(dynamic value) {
    if (value == null) return VendorDocumentType.other;
    final stringValue = value.toString().toLowerCase();
    return VendorDocumentType.values.firstWhere(
      (type) => type.value == stringValue,
      orElse: () => VendorDocumentType.other,
    );
  }

  static DocumentVerificationStatus _parseVerificationStatus(dynamic value) {
    if (value == null) return DocumentVerificationStatus.pending;
    final stringValue = value.toString().toLowerCase();
    return DocumentVerificationStatus.values.firstWhere(
      (status) => status.value == stringValue,
      orElse: () => DocumentVerificationStatus.pending,
    );
  }
}

enum VendorDocumentType {
  nationalId('national_id', 'National ID / Passport'),
  businessLicense('business_license', 'Business License'),
  taxCertificate('tax_certificate', 'Tax Certificate'),
  foodSafetyCertificate('food_safety_certificate', 'Food Safety Certificate'),
  proofOfAddress('proof_of_address', 'Proof of Address'),
  bankStatement('bank_statement', 'Bank Statement'),
  driverLicense('driver_license', 'Driver\'s License'),
  vehicleRegistration('vehicle_registration', 'Vehicle Registration'),
  vehicleInsurance('vehicle_insurance', 'Vehicle Insurance'),
  healthPermit('health_permit', 'Health Permit'),
  businessPhoto('business_photo', 'Business Photo'),
  other('other', 'Other Document');

  final String value;
  final String displayName;

  const VendorDocumentType(this.value, this.displayName);

  static List<VendorDocumentType> get requiredDocuments => [
        VendorDocumentType.nationalId,
        VendorDocumentType.businessLicense,
      ];

  static List<VendorDocumentType> get optionalDocuments => [
        VendorDocumentType.taxCertificate,
        VendorDocumentType.foodSafetyCertificate,
        VendorDocumentType.proofOfAddress,
        VendorDocumentType.bankStatement,
        VendorDocumentType.driverLicense,
        VendorDocumentType.vehicleRegistration,
        VendorDocumentType.vehicleInsurance,
        VendorDocumentType.healthPermit,
        VendorDocumentType.businessPhoto,
        VendorDocumentType.other,
      ];
}

enum DocumentVerificationStatus {
  pending('pending', 'Pending Review'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  expired('expired', 'Expired');

  final String value;
  final String displayName;

  const DocumentVerificationStatus(this.value, this.displayName);
}

