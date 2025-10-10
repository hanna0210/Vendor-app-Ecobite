import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuodz/models/document_type.dart';
import 'package:fuodz/views/pages/auth/vendor_application.page.dart';
import 'package:fuodz/widgets/cards/document_upload_card.dart';
import 'package:fuodz/widgets/forms/vendor_application_form.dart';

/// Example: How to use the Document Upload System
/// 
/// This file demonstrates various ways to integrate and use the
/// document upload components in your application.

// ============================================================
// Example 1: Navigate to Standalone Vendor Application Page
// ============================================================

class NavigateToApplicationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Simply navigate to the vendor application page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorApplicationPage(),
          ),
        );
      },
      child: Text('Apply as Vendor'),
    );
  }
}

// ============================================================
// Example 2: Use Application Form in Custom Page
// ============================================================

class CustomApplicationPage extends StatefulWidget {
  @override
  _CustomApplicationPageState createState() => _CustomApplicationPageState();
}

class _CustomApplicationPageState extends State<CustomApplicationPage> {
  Map<String, File> uploadedDocuments = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Application')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Upload Your Documents',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Use the vendor application form
            VendorApplicationForm(
              onDocumentsChanged: (documents) {
                setState(() {
                  uploadedDocuments = documents;
                });
                print('Total documents uploaded: ${documents.length}');
              },
              initialDocuments: uploadedDocuments,
            ),
            
            SizedBox(height: 20),
            
            // Submit button
            ElevatedButton(
              onPressed: uploadedDocuments.isEmpty
                  ? null
                  : () {
                      // Handle submission
                      _submitDocuments();
                    },
              child: Text('Submit Documents'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDocuments() {
    // Implement your submission logic
    print('Submitting ${uploadedDocuments.length} documents...');
    
    uploadedDocuments.forEach((documentTypeId, file) {
      print('Document: $documentTypeId -> ${file.path}');
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Documents submitted successfully!')),
    );
  }
}

// ============================================================
// Example 3: Use Individual Document Upload Card
// ============================================================

class SingleDocumentUploadExample extends StatefulWidget {
  @override
  _SingleDocumentUploadExampleState createState() =>
      _SingleDocumentUploadExampleState();
}

class _SingleDocumentUploadExampleState
    extends State<SingleDocumentUploadExample> {
  File? uploadedFile;

  @override
  Widget build(BuildContext context) {
    // Create a custom document type
    final documentType = DocumentType(
      id: 'profile_photo',
      name: 'Profile Photo',
      description: 'Upload a clear photo of yourself',
      required: true,
      acceptedFormats: ['jpg', 'jpeg', 'png'],
      maxSizeMB: 2,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Upload Profile Photo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Single document upload card
            DocumentUploadCard(
              documentType: documentType,
              onFileSelected: (file, documentTypeId) {
                setState(() {
                  uploadedFile = file;
                });
                print('File selected: ${file.path}');
              },
              onFileRemoved: (documentTypeId) {
                setState(() {
                  uploadedFile = null;
                });
                print('File removed');
              },
            ),
            
            SizedBox(height: 20),
            
            if (uploadedFile != null)
              Text('File uploaded: ${uploadedFile!.path}'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Example 4: Create Custom Document Types
// ============================================================

class CustomDocumentTypesExample {
  static List<DocumentType> getRestaurantDocuments() {
    return [
      DocumentType(
        id: 'health_permit',
        name: 'Health Department Permit',
        description: 'Upload your valid health department permit',
        required: true,
        acceptedFormats: ['pdf', 'jpg', 'png'],
        maxSizeMB: 5,
      ),
      DocumentType(
        id: 'liquor_license',
        name: 'Liquor License',
        description: 'Upload liquor license (if applicable)',
        required: false,
        acceptedFormats: ['pdf'],
        maxSizeMB: 5,
      ),
      DocumentType(
        id: 'fire_safety',
        name: 'Fire Safety Certificate',
        description: 'Upload fire safety inspection certificate',
        required: true,
        acceptedFormats: ['pdf', 'jpg', 'png'],
        maxSizeMB: 5,
      ),
    ];
  }

  static List<DocumentType> getDeliveryDriverDocuments() {
    return [
      DocumentType(
        id: 'drivers_license',
        name: "Driver's License",
        description: 'Upload a clear photo of your valid driver\'s license',
        required: true,
        acceptedFormats: ['jpg', 'jpeg', 'png'],
        maxSizeMB: 3,
      ),
      DocumentType(
        id: 'vehicle_insurance',
        name: 'Vehicle Insurance',
        description: 'Upload proof of vehicle insurance',
        required: true,
        acceptedFormats: ['pdf', 'jpg', 'png'],
        maxSizeMB: 5,
      ),
      DocumentType(
        id: 'background_check',
        name: 'Background Check',
        description: 'Upload background check results',
        required: true,
        acceptedFormats: ['pdf'],
        maxSizeMB: 5,
      ),
    ];
  }
}

// ============================================================
// Example 5: Embedded in Registration with Callback
// ============================================================

class ApplicationWithCallbackExample extends StatelessWidget {
  final Function(Map<String, File>)? onSubmit;

  const ApplicationWithCallbackExample({this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return VendorApplicationPage(
      isStandalone: false, // Embedded mode
      onDocumentsSubmitted: (documents) {
        // Custom callback when documents are submitted
        print('Documents submitted: ${documents.length}');
        
        if (onSubmit != null) {
          onSubmit!(documents);
        }
        
        // Navigate to next step
        Navigator.pop(context, documents);
      },
    );
  }
}

// ============================================================
// Example 6: Check Required Documents
// ============================================================

class DocumentValidationExample {
  static bool areRequiredDocumentsUploaded(Map<String, File> documents) {
    final requiredDocs = DocumentType.getVendorDocumentTypes()
        .where((doc) => doc.required)
        .map((doc) => doc.id)
        .toList();
    
    for (var docId in requiredDocs) {
      if (!documents.containsKey(docId)) {
        print('Missing required document: $docId');
        return false;
      }
    }
    
    return true;
  }

  static int getUploadProgress(Map<String, File> documents) {
    final requiredDocs = DocumentType.getVendorDocumentTypes()
        .where((doc) => doc.required)
        .length;
    
    final uploadedRequired = DocumentType.getVendorDocumentTypes()
        .where((doc) => doc.required && documents.containsKey(doc.id))
        .length;
    
    return ((uploadedRequired / requiredDocs) * 100).round();
  }
}

// ============================================================
// Example 7: Menu Item to Launch Application
// ============================================================

class VendorMenuExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.upload_file),
      title: Text('Submit Verification Documents'),
      subtitle: Text('Upload ID, license, and other documents'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorApplicationPage(),
          ),
        );
      },
    );
  }
}

// ============================================================
// Usage Instructions:
// ============================================================
/*

1. STANDALONE PAGE:
   - Use VendorApplicationPage() for a complete application flow
   - Includes progress indicator, submit button, and validation

2. EMBEDDED FORM:
   - Use VendorApplicationForm() to embed in your custom pages
   - Get document updates via onDocumentsChanged callback

3. CUSTOM DOCUMENTS:
   - Create custom DocumentType instances
   - Use DocumentUploadCard for individual uploads

4. VALIDATION:
   - Use DocumentValidationExample methods to check completion
   - areRequiredDocumentsUploaded() returns true/false
   - getUploadProgress() returns percentage (0-100)

5. INTEGRATION IN EXISTING FLOW:
   - The register page already includes the enhanced form
   - Can be used separately or as part of registration

6. CALLBACKS:
   - onDocumentsChanged: Called when any document is added/removed
   - onDocumentsSubmitted: Called when user submits the application

*/

