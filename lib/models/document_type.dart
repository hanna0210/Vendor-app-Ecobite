import 'dart:io';

class DocumentType {
  final String id;
  final String name;
  final String description;
  final bool required;
  final List<String> acceptedFormats;
  final int maxSizeMB;
  File? file;

  DocumentType({
    required this.id,
    required this.name,
    required this.description,
    this.required = true,
    this.acceptedFormats = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.maxSizeMB = 5,
    this.file,
  });

  bool get isUploaded => file != null;

  // Predefined document types for vendor registration
  static List<DocumentType> getVendorDocumentTypes() {
    return [
      DocumentType(
        id: 'national_id',
        name: 'National ID / Passport',
        description: 'Upload a clear photo of your government-issued ID or passport',
        required: true,
      ),
      DocumentType(
        id: 'business_license',
        name: 'Business License',
        description: 'Upload your valid business registration or trading license',
        required: true,
      ),
      DocumentType(
        id: 'tax_certificate',
        name: 'Tax Certificate',
        description: 'Upload your tax registration certificate (if applicable)',
        required: false,
      ),
      DocumentType(
        id: 'driver_license',
        name: 'Driver\'s License',
        description: 'Upload your valid driver\'s license (for delivery services)',
        required: false,
      ),
      DocumentType(
        id: 'vehicle_registration',
        name: 'Vehicle Registration',
        description: 'Upload vehicle registration document (for delivery services)',
        required: false,
      ),
      DocumentType(
        id: 'vehicle_insurance',
        name: 'Vehicle Insurance',
        description: 'Upload proof of vehicle insurance (for delivery services)',
        required: false,
      ),
      DocumentType(
        id: 'food_safety_certificate',
        name: 'Food Safety Certificate',
        description: 'Upload food handling/safety certificate (for food vendors)',
        required: false,
      ),
      DocumentType(
        id: 'bank_statement',
        name: 'Bank Statement',
        description: 'Upload recent bank statement or bank account verification',
        required: false,
      ),
      DocumentType(
        id: 'address_proof',
        name: 'Proof of Address',
        description: 'Upload utility bill or lease agreement as proof of business address',
        required: false,
      ),
      DocumentType(
        id: 'other_documents',
        name: 'Other Documents',
        description: 'Upload any additional supporting documents',
        required: false,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'required': required,
      'accepted_formats': acceptedFormats,
      'max_size_mb': maxSizeMB,
      'is_uploaded': isUploaded,
    };
  }
}

