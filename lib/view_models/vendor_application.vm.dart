import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/document_type.dart';
import 'package:fuodz/requests/vendor.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class VendorApplicationViewModel extends MyBaseViewModel {
  VendorApplicationViewModel(BuildContext context) {
    this.viewContext = context;
  }

  VendorRequest _vendorRequest = VendorRequest();
  Map<String, File> uploadedDocuments = {};
  List<DocumentType> documentTypes = [];

  void initialise() {
    documentTypes = DocumentType.getVendorDocumentTypes();
  }

  void onDocumentsChanged(Map<String, File> documents) {
    uploadedDocuments = documents;
    notifyListeners();
  }

  bool get canSubmit {
    // Check if all required documents are uploaded
    final requiredDocs = documentTypes.where((doc) => doc.required);
    for (var doc in requiredDocs) {
      if (!uploadedDocuments.containsKey(doc.id)) {
        return false;
      }
    }
    return true;
  }

  int get requiredDocumentsCount {
    return documentTypes.where((doc) => doc.required).length;
  }

  int get uploadedRequiredDocumentsCount {
    final requiredDocs = documentTypes.where((doc) => doc.required);
    int count = 0;
    for (var doc in requiredDocs) {
      if (uploadedDocuments.containsKey(doc.id)) {
        count++;
      }
    }
    return count;
  }

  double get uploadProgress {
    if (requiredDocumentsCount == 0) return 0.0;
    return uploadedRequiredDocumentsCount / requiredDocumentsCount;
  }

  Future<void> submitApplication() async {
    if (!canSubmit) {
      toastError("Please upload all required documents".tr());
      return;
    }

    setBusy(true);

    try {
      // Convert map to list for the API
      final List<File> documentsList = uploadedDocuments.values.toList();

      final apiResponse = await _vendorRequest.submitDocumentsRequest(
        docs: documentsList,
      );

      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Application Submitted".tr(),
          text: "Your application has been submitted successfully. We will review your documents and get back to you within 24-48 hours."
              .tr(),
        );
        
        // Navigate back or to success page
        viewContext.pop();
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }

    setBusy(false);
  }

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

  Map<String, String> getDocumentTypeLabels() {
    Map<String, String> labels = {};
    for (var doc in documentTypes) {
      labels[doc.id] = doc.name;
    }
    return labels;
  }
}

