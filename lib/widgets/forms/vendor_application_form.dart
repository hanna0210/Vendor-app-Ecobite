import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/document_type.dart';
import 'package:fuodz/utils/utils.dart' as app_utils;
import 'package:fuodz/widgets/cards/document_upload_card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorApplicationForm extends StatefulWidget {
  VendorApplicationForm({
    Key? key,
    required this.onDocumentsChanged,
    this.initialDocuments,
  }) : super(key: key);

  final Function(Map<String, File> documents) onDocumentsChanged;
  final Map<String, File>? initialDocuments;

  @override
  State<VendorApplicationForm> createState() => _VendorApplicationFormState();
}

class _VendorApplicationFormState extends State<VendorApplicationForm> {
  List<DocumentType> documentTypes = [];
  Map<String, File> uploadedDocuments = {};

  @override
  void initState() {
    super.initState();
    documentTypes = DocumentType.getVendorDocumentTypes();
    uploadedDocuments = widget.initialDocuments ?? {};
    
    // Set initial files if provided
    if (uploadedDocuments.isNotEmpty) {
      for (var doc in documentTypes) {
        if (uploadedDocuments.containsKey(doc.id)) {
          doc.file = uploadedDocuments[doc.id];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        // Header
        _buildHeader(),
        20.heightBox,

        // Required Documents Section
        _buildSectionTitle("Required Documents".tr(), true),
        12.heightBox,
        ...documentTypes
            .where((doc) => doc.required)
            .map((doc) => DocumentUploadCard(
                  documentType: doc,
                  onFileSelected: _onFileSelected,
                  onFileRemoved: _onFileRemoved,
                ))
            .toList(),

        24.heightBox,

        // Optional Documents Section
        _buildSectionTitle("Optional Documents".tr(), false),
        8.heightBox,
        "Upload any additional documents that may support your application"
            .tr()
            .text
            .sm
            .gray600
            .make()
            .py4(),
        12.heightBox,
        ...documentTypes
            .where((doc) => !doc.required)
            .map((doc) => DocumentUploadCard(
                  documentType: doc,
                  onFileSelected: _onFileSelected,
                  onFileRemoved: _onFileRemoved,
                ))
            .toList(),

        24.heightBox,

        // Upload Summary
        _buildUploadSummary(),
      ],
    );
  }

  Widget _buildHeader() {
    return VStack(
      [
        "Verification Documents"
            .tr()
            .text
            .xl3
            .bold
            .color(app_utils.Utils.textColorByTheme())
            .make(),
        8.heightBox,
        "Please upload the following documents to verify your account. Required documents must be submitted before your application can be processed."
            .tr()
            .text
            .sm
            .gray600
            .make(),
        12.heightBox,
        _buildInfoBox(
          "Important Notes".tr(),
          [
            "All documents must be clear and readable".tr(),
            "Accepted formats: PDF, JPG, PNG".tr(),
            "Maximum file size: 5MB per document".tr(),
            "Documents will be verified within 24-48 hours".tr(),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool required) {
    return HStack(
      [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        12.widthBox,
        title.text.xl2.bold.make().expand(),
        if (required)
          VxBox(
            child: "Required".tr().text.white.sm.make(),
          ).red500.roundedSM.px12.py4.make()
        else
          VxBox(
            child: "Optional".tr().text.white.sm.make(),
          ).gray500.roundedSM.px12.py4.make(),
      ],
    ).py8();
  }

  Widget _buildInfoBox(String title, List<String> points) {
    return VStack(
      [
        title.text.semiBold.make().py4(),
        ...points.map(
          (point) => HStack(
            [
              Icon(Icons.check_circle, size: 16, color: AppColor.primaryColor),
              8.widthBox,
              point.text.sm.make().expand(),
            ],
          ).py2(),
        ),
      ],
    )
        .p16()
        .box
        .roundedSM
        .color(AppColor.primaryColor.withOpacity(0.05))
        .border(color: AppColor.primaryColor.withOpacity(0.2))
        .make();
  }

  Widget _buildUploadSummary() {
    final requiredDocs = documentTypes.where((doc) => doc.required).length;
    final requiredUploaded =
        documentTypes.where((doc) => doc.required && doc.isUploaded).length;
    final optionalUploaded =
        documentTypes.where((doc) => !doc.required && doc.isUploaded).length;
    final totalUploaded = uploadedDocuments.length;

    final progress = requiredDocs > 0 ? requiredUploaded / requiredDocs : 0.0;

    return VStack(
      [
        HStack(
          [
            "Upload Progress".tr().text.lg.semiBold.make().expand(),
            "$requiredUploaded / $requiredDocs"
                .text
                .lg
                .bold
                .color(
                  requiredUploaded == requiredDocs
                      ? Colors.green
                      : AppColor.primaryColor,
                )
                .make(),
          ],
        ).py8(),

        // Progress bar
        VStack(
          [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade200,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: requiredUploaded == requiredDocs
                        ? Colors.green
                        : AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ).py8(),

        // Summary stats
        HStack(
          [
            _buildStatCard(
              "Required",
              "$requiredUploaded/$requiredDocs",
              requiredUploaded == requiredDocs ? Colors.green : Colors.orange,
            ).expand(),
            12.widthBox,
            _buildStatCard(
              "Optional",
              "$optionalUploaded",
              AppColor.primaryColor,
            ).expand(),
            12.widthBox,
            _buildStatCard(
              "Total",
              "$totalUploaded",
              AppColor.primaryColor,
            ).expand(),
          ],
        ),

        12.heightBox,

        // Validation message
        if (requiredUploaded < requiredDocs)
          HStack(
            [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              8.widthBox,
              "Please upload all required documents to continue"
                  .tr()
                  .text
                  .sm
                  .orange600
                  .make()
                  .expand(),
            ],
          )
              .p12()
              .box
              .roundedSM
              .color(Colors.orange.shade50)
              .border(color: Colors.orange.shade200)
              .make()
        else
          HStack(
            [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              8.widthBox,
              "All required documents uploaded successfully!"
                  .tr()
                  .text
                  .sm
                  .green700
                  .make()
                  .expand(),
            ],
          )
              .p12()
              .box
              .roundedSM
              .color(Colors.green.shade50)
              .border(color: Colors.green.shade200)
              .make(),
      ],
    )
        .p16()
        .box
        .roundedLg
        .color(context.cardColor)
        .border(color: Colors.grey.shade300)
        .shadowSm
        .make();
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return VStack(
      [
        value.text.xl.bold.color(color).make(),
        4.heightBox,
        label.tr().text.xs.gray600.make(),
      ],
      crossAlignment: CrossAxisAlignment.center,
    )
        .p12()
        .box
        .roundedSM
        .color(color.withOpacity(0.05))
        .border(color: color.withOpacity(0.2))
        .make();
  }

  void _onFileSelected(File file, String documentTypeId) {
    setState(() {
      uploadedDocuments[documentTypeId] = file;
      // Update document type
      final docType = documentTypes.firstWhere((doc) => doc.id == documentTypeId);
      docType.file = file;
    });
    widget.onDocumentsChanged(uploadedDocuments);
  }

  void _onFileRemoved(String documentTypeId) {
    setState(() {
      uploadedDocuments.remove(documentTypeId);
      // Update document type
      final docType = documentTypes.firstWhere((doc) => doc.id == documentTypeId);
      docType.file = null;
    });
    widget.onDocumentsChanged(uploadedDocuments);
  }
}


