import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/vendor_document.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorDocumentUploadView extends StatefulWidget {
  const VendorDocumentUploadView({
    Key? key,
    required this.documentType,
    required this.onDocumentSelected,
    this.initialDocument,
    this.isRequired = false,
  }) : super(key: key);

  final VendorDocumentType documentType;
  final Function(VendorDocument?) onDocumentSelected;
  final VendorDocument? initialDocument;
  final bool isRequired;

  @override
  State<VendorDocumentUploadView> createState() =>
      _VendorDocumentUploadViewState();
}

class _VendorDocumentUploadViewState extends State<VendorDocumentUploadView> {
  final _formKey = GlobalKey<FormBuilderState>();
  VendorDocument? currentDocument;
  bool hasFile = false;

  @override
  void initState() {
    super.initState();
    currentDocument = widget.initialDocument ??
        VendorDocument(documentType: widget.documentType);
    hasFile = currentDocument?.file != null || currentDocument?.filePath != null;
  }

  @override
  Widget build(BuildContext context) {
    final inputDec = InputDecoration(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: context.cardColor,
    );

    return FormBuilder(
      key: _formKey,
      child: VStack(
        [
          // Document Type Header
          HStack(
            [
              Icon(
                _getDocumentIcon(),
                color: AppColor.primaryColor,
                size: 24,
              ),
              UiSpacer.hSpace(10),
              VStack(
                [
                  widget.documentType.displayName.text.semiBold.lg.make(),
                  if (widget.isRequired)
                    "Required".tr().text.red500.sm.make()
                  else
                    "Optional".tr().text.gray500.sm.make(),
                ],
                crossAlignment: CrossAxisAlignment.start,
              ).expand(),
            ],
          ).py8(),

          UiSpacer.divider(thickness: 1).py8(),

          // File Upload Section
          _buildFileUploadSection(context),

          // Document Details (shown only if file is uploaded)
          if (hasFile) ...[
            UiSpacer.vSpace(16),
            
            // Document Number
            FormBuilderTextField(
              name: '${widget.documentType.value}_document_number',
              initialValue: currentDocument?.documentNumber,
              decoration: inputDec.copyWith(
                labelText: "Document Number".tr(),
                hintText: "Enter document number".tr(),
                prefixIcon: Icon(FlutterIcons.hash_fea),
              ),
              validator: widget.isRequired
                  ? CustomFormBuilderValidator.required
                  : null,
              onChanged: (value) {
                currentDocument?.documentNumber = value;
                _notifyUpdate();
              },
            ),

            UiSpacer.vSpace(12),

            // Issued Date
            FormBuilderDateTimePicker(
              name: '${widget.documentType.value}_issued_date',
              initialValue: currentDocument?.issuedDate,
              inputType: InputType.date,
              format: DateFormat('yyyy-MM-dd'),
              decoration: inputDec.copyWith(
                labelText: "Issued Date".tr(),
                hintText: "Select issued date".tr(),
                prefixIcon: Icon(FlutterIcons.calendar_ant),
              ),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              onChanged: (value) {
                currentDocument?.issuedDate = value;
                _notifyUpdate();
              },
            ),

            UiSpacer.vSpace(12),

            // Expiry Date
            if (_hasExpiryDate()) ...[
              FormBuilderDateTimePicker(
                name: '${widget.documentType.value}_expiry_date',
                initialValue: currentDocument?.expiryDate,
                inputType: InputType.date,
                format: DateFormat('yyyy-MM-dd'),
                decoration: inputDec.copyWith(
                  labelText: "Expiry Date".tr(),
                  hintText: "Select expiry date".tr(),
                  prefixIcon: Icon(FlutterIcons.calendar_fea),
                ),
                validator: (value) {
                  if (widget.isRequired && value == null) {
                    return "Expiry date is required".tr();
                  }
                  if (value != null && value.isBefore(DateTime.now())) {
                    return "Document has expired".tr();
                  }
                  return null;
                },
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 3650)), // 10 years
                onChanged: (value) {
                  currentDocument?.expiryDate = value;
                  _notifyUpdate();
                },
              ),
              UiSpacer.vSpace(12),
            ],

            // Issuing Authority
            FormBuilderTextField(
              name: '${widget.documentType.value}_issuing_authority',
              initialValue: currentDocument?.issuingAuthority,
              decoration: inputDec.copyWith(
                labelText: "Issuing Authority".tr(),
                hintText: "e.g., Ministry of Commerce".tr(),
                prefixIcon: Icon(FlutterIcons.building_faw5s),
              ),
              onChanged: (value) {
                currentDocument?.issuingAuthority = value;
                _notifyUpdate();
              },
            ),
          ],
        ],
      )
          .p16()
          .box
          .roundedSM
          .border(
            color: widget.isRequired
                ? (hasFile ? Colors.green : Colors.orange)
                : Colors.grey.shade300,
            width: 2,
          )
          .color(context.cardColor)
          .shadowSm
          .make()
          .py8(),
    );
  }

  Widget _buildFileUploadSection(BuildContext context) {
    return VStack(
      [
        if (!hasFile)
          // Empty state - show upload button
          VStack(
            [
              Icon(
                FlutterIcons.upload_cloud_fea,
                size: 48,
                color: Colors.grey.shade400,
              ),
              UiSpacer.vSpace(8),
              "Tap to upload ${widget.documentType.displayName}"
                  .tr()
                  .text
                  .center
                  .gray600
                  .make(),
              UiSpacer.vSpace(4),
              "Supported: PDF, JPG, PNG (Max 10MB)"
                  .tr()
                  .text
                  .xs
                  .gray500
                  .center
                  .make(),
            ],
            crossAlignment: CrossAxisAlignment.center,
          )
              .p20()
              .box
              .roundedSM
              .border(
                color: Colors.grey.shade300,
                width: 2,
              )
              .border(style: BorderStyle.solid)
              .make()
              .wFull(context)
              .onInkTap(_pickDocument)
        else
          // File selected state
          HStack(
            [
              // File icon
              Icon(
                _getFileIcon(),
                color: AppColor.primaryColor,
                size: 32,
              ),
              UiSpacer.hSpace(12),
              // File details
              VStack(
                [
                  (currentDocument?.file?.path.split('/').last ??
                          currentDocument?.filePath?.split('/').last ??
                          "Document uploaded")
                      .text
                      .semiBold
                      .maxLines(1)
                      .ellipsis
                      .make(),
                  if (currentDocument?.file != null)
                    _getFileSize(currentDocument!.file!).text.sm.gray600.make(),
                  _getStatusBadge(),
                ],
                crossAlignment: CrossAxisAlignment.start,
              ).expand(),
              // Actions
              HStack(
                [
                  // Change file button
                  Icon(
                    FlutterIcons.edit_faw5,
                    color: AppColor.primaryColor,
                    size: 20,
                  ).p8().onInkTap(_pickDocument),
                  // Remove file button
                  Icon(
                    FlutterIcons.trash_alt_faw5,
                    color: Colors.red,
                    size: 20,
                  ).p8().onInkTap(_removeDocument),
                ],
              ),
            ],
          )
              .p12()
              .box
              .roundedSM
              .color(Colors.green.shade50)
              .border(color: Colors.green.shade300)
              .make(),
      ],
    );
  }

  Widget _getStatusBadge() {
    if (currentDocument?.verificationStatus == null) {
      return SizedBox.shrink();
    }

    Color badgeColor;
    IconData badgeIcon;

    switch (currentDocument!.verificationStatus) {
      case DocumentVerificationStatus.approved:
        badgeColor = Colors.green;
        badgeIcon = FlutterIcons.check_circle_fea;
        break;
      case DocumentVerificationStatus.rejected:
        badgeColor = Colors.red;
        badgeIcon = FlutterIcons.x_circle_fea;
        break;
      case DocumentVerificationStatus.expired:
        badgeColor = Colors.orange;
        badgeIcon = FlutterIcons.alert_circle_fea;
        break;
      default:
        badgeColor = Colors.blue;
        badgeIcon = FlutterIcons.clock_fea;
    }

    return HStack(
      [
        Icon(badgeIcon, color: badgeColor, size: 14),
        UiSpacer.hSpace(4),
        currentDocument!.verificationStatus.displayName.text.sm
            .color(badgeColor)
            .make(),
      ],
    ).py4();
  }

  IconData _getDocumentIcon() {
    switch (widget.documentType) {
      case VendorDocumentType.nationalId:
        return FlutterIcons.id_card_faw5;
      case VendorDocumentType.businessLicense:
        return FlutterIcons.briefcase_fea;
      case VendorDocumentType.taxCertificate:
        return FlutterIcons.file_text_fea;
      case VendorDocumentType.foodSafetyCertificate:
        return FlutterIcons.award_fea;
      case VendorDocumentType.proofOfAddress:
        return FlutterIcons.home_fea;
      case VendorDocumentType.bankStatement:
        return FlutterIcons.credit_card_fea;
      case VendorDocumentType.driverLicense:
        return FlutterIcons.id_card_faw5;
      case VendorDocumentType.vehicleRegistration:
        return FlutterIcons.file_text_fea;
      case VendorDocumentType.vehicleInsurance:
        return FlutterIcons.shield_fea;
      case VendorDocumentType.healthPermit:
        return FlutterIcons.heart_fea;
      case VendorDocumentType.businessPhoto:
        return FlutterIcons.camera_fea;
      default:
        return FlutterIcons.file_fea;
    }
  }

  IconData _getFileIcon() {
    final fileName = currentDocument?.file?.path ?? currentDocument?.filePath ?? '';
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return FlutterIcons.file_pdf_faw5;
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      return FlutterIcons.image_fea;
    }
    return FlutterIcons.file_fea;
  }

  bool _hasExpiryDate() {
    return widget.documentType == VendorDocumentType.businessLicense ||
        widget.documentType == VendorDocumentType.taxCertificate ||
        widget.documentType == VendorDocumentType.foodSafetyCertificate ||
        widget.documentType == VendorDocumentType.healthPermit ||
        widget.documentType == VendorDocumentType.driverLicense ||
        widget.documentType == VendorDocumentType.vehicleInsurance ||
        widget.documentType == VendorDocumentType.nationalId;
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSize = file.lengthSync();

      // Check file size (max 10MB)
      if (fileSize > 10 * 1024 * 1024) {
        // Show error toast
        context.showToast(
          msg: "File size must be less than 10MB".tr(),
          bgColor: Colors.red,
        );
        return;
      }

      setState(() {
        currentDocument?.file = file;
        currentDocument?.filePath = result.files.single.path;
        hasFile = true;
      });

      _notifyUpdate();
    }
  }

  void _removeDocument() {
    setState(() {
      currentDocument?.file = null;
      currentDocument?.filePath = null;
      hasFile = false;
    });
    widget.onDocumentSelected(null);
  }

  void _notifyUpdate() {
    if (hasFile && _formKey.currentState?.saveAndValidate() == true) {
      widget.onDocumentSelected(currentDocument);
    } else if (!hasFile) {
      widget.onDocumentSelected(null);
    }
  }

  bool validateDocument() {
    return _formKey.currentState?.saveAndValidate() ?? false;
  }
}

