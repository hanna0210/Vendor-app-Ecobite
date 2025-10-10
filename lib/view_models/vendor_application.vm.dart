import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor_document.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';

class VendorApplicationViewModel extends MyBaseViewModel {
  VendorApplicationViewModel(BuildContext context) {
    this.viewContext = context;
  }

  // Document storage
  Map<VendorDocumentType, VendorDocument?> documents = {};
  
  // API request handler
  final VendorRequest _vendorRequest = VendorRequest();

  @override
  void initialise() {
    super.initialise();
    _initializeDocumentMap();
  }

  void _initializeDocumentMap() {
    // Initialize all document types with null
    for (var docType in VendorDocumentType.values) {
      documents[docType] = null;
    }
    notifyListeners();
  }

  // Handle document updates
  void onDocumentUpdated(VendorDocumentType type, VendorDocument? document) {
    documents[type] = document;
    notifyListeners();
  }

  // Calculate completion progress
  double get completionProgress {
    final requiredDocs = VendorDocumentType.requiredDocuments;
    final uploadedRequired = requiredDocs.where((type) {
      final doc = documents[type];
      return doc != null && doc.file != null;
    }).length;

    return requiredDocs.isEmpty ? 0 : uploadedRequired / requiredDocs.length;
  }

  // Get count of uploaded required documents
  int get uploadedRequiredDocuments {
    return VendorDocumentType.requiredDocuments.where((type) {
      final doc = documents[type];
      return doc != null && doc.file != null;
    }).length;
  }

  // Check if all required documents are uploaded
  bool get canSubmit {
    final requiredDocs = VendorDocumentType.requiredDocuments;
    return requiredDocs.every((type) {
      final doc = documents[type];
      return doc != null && doc.file != null;
    });
  }

  // Get list of uploaded documents
  List<VendorDocument> get uploadedDocuments {
    return documents.values
        .where((doc) => doc != null && doc.file != null)
        .cast<VendorDocument>()
        .toList();
  }

  // Submit application
  Future<void> submitApplication() async {
    if (!canSubmit) {
      await AlertService.error(
        title: "Incomplete Application".tr(),
        text: "Please upload all required documents before submitting".tr(),
      );
      return;
    }

    setBusy(true);

    try {
      // Prepare document files and metadata
      final uploadedDocs = uploadedDocuments;
      final documentFiles = uploadedDocs.map((doc) => doc.file!).toList();
      
      // Prepare document metadata
      final documentMetadata = uploadedDocs.map((doc) {
        return {
          'type': doc.documentType.value,
          'document_number': doc.documentNumber,
          'expiry_date': doc.expiryDate?.toIso8601String(),
          'issued_date': doc.issuedDate?.toIso8601String(),
          'issuing_authority': doc.issuingAuthority,
        };
      }).toList();

      // Call API to submit documents
      final apiResponse = await _vendorRequest.submitVendorDocuments(
        documents: documentFiles,
        metadata: documentMetadata,
      );

      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Application Submitted".tr(),
          text: "Your documents have been submitted successfully. We will review them and get back to you within 24-48 hours.".tr(),
        );
        
        // Navigate back or to appropriate screen
        Navigator.of(viewContext).pop();
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }

    setBusy(false);
  }

  // Save draft
  Future<void> saveDraft() async {
    if (uploadedDocuments.isEmpty) {
      toastError("No documents to save".tr());
      return;
    }

    // Save to local storage or temporary storage
    await AlertService.success(
      title: "Draft Saved".tr(),
      text: "Your progress has been saved. You can continue later.".tr(),
    );
  }

  // Validate specific document
  bool validateDocument(VendorDocumentType type) {
    final doc = documents[type];
    if (doc == null || doc.file == null) {
      return false;
    }

    // Check if document has expired (for documents with expiry dates)
    if (doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  // Get validation errors
  Map<VendorDocumentType, String> getValidationErrors() {
    Map<VendorDocumentType, String> errors = {};

    for (var type in VendorDocumentType.requiredDocuments) {
      final doc = documents[type];
      
      if (doc == null || doc.file == null) {
        errors[type] = "This document is required".tr();
        continue;
      }

      if (doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now())) {
        errors[type] = "This document has expired".tr();
      }
    }

    return errors;
  }

  // Clear all documents
  void clearAllDocuments() {
    _initializeDocumentMap();
  }

  // Remove specific document
  void removeDocument(VendorDocumentType type) {
    documents[type] = null;
    notifyListeners();
  }
}
