import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_sizes/file_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/document_type.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class DocumentUploadCard extends StatefulWidget {
  DocumentUploadCard({
    Key? key,
    required this.documentType,
    required this.onFileSelected,
    this.onFileRemoved,
  }) : super(key: key);

  final DocumentType documentType;
  final Function(File file, String documentTypeId) onFileSelected;
  final Function(String documentTypeId)? onFileRemoved;

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  File? selectedFile;
  PlatformFile? selectedPlatformFile;

  @override
  void initState() {
    super.initState();
    selectedFile = widget.documentType.file;
  }

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        // Document title with required indicator
        HStack(
          [
            widget.documentType.name.text.semiBold.lg.make().expand(),
            if (widget.documentType.required)
              "*"
                  .text
                  .red500
                  .xl
                  .make()
                  .pOnly(left: 4)
            else
              "(Optional)"
                  .tr()
                  .text
                  .gray500
                  .sm
                  .make()
                  .pOnly(left: 4),
          ],
        ).py8(),

        // Description
        widget.documentType.description.text.sm.gray600.make().py4(),

        // File size and format info
        HStack(
          [
            Icon(FlutterIcons.info_outline_mdi, size: 14, color: Colors.grey),
            UiSpacer.horizontalSpace(space: 4),
            "Max ${widget.documentType.maxSizeMB}MB • ${widget.documentType.acceptedFormats.join(', ').toUpperCase()}"
                .text
                .xs
                .gray500
                .make(),
          ],
        ).py4(),

        // Upload area
        selectedFile == null
            ? _buildUploadArea()
            : _buildUploadedFileCard(),
      ],
    )
        .p16()
        .box
        .roundedLg
        .border(
          color: widget.documentType.required
              ? AppColor.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        )
        .color(context.cardColor)
        .shadowSm
        .make()
        .py8();
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _openFileSelector,
      child: VStack(
        [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: AppColor.primaryColor.withOpacity(0.7),
          ),
          12.heightBox,
          "Tap to upload"
              .tr()
              .text
              .semiBold
              .color(AppColor.primaryColor)
              .make(),
          4.heightBox,
          "or drag and drop your file here"
              .tr()
              .text
              .sm
              .gray500
              .center
              .make(),
        ],
        crossAlignment: CrossAxisAlignment.center,
      )
          .centered()
          .p32()
          .box
          .roundedSM
          .border(color: Colors.grey.shade300, width: 2)
          .make(),
    );
  }

  Widget _buildUploadedFileCard() {
    return HStack(
      [
        // File icon
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileIcon(),
            color: Colors.white,
            size: 24,
          ),
        ),

        SizedBox(width: 12),

        // File info
        VStack(
          [
            (selectedPlatformFile?.name ?? "Document")
                .text
                .semiBold
                .maxLines(1)
                .ellipsis
                .make(),
            4.heightBox,
            HStack([
              if (selectedPlatformFile != null)
                "${FileSize.getSize(selectedPlatformFile!.size)}"
                    .text
                    .sm
                    .gray600
                    .make(),
              if (selectedPlatformFile != null) " • ".text.gray600.make(),
              "${selectedPlatformFile?.extension ?? ''}"
                  .text
                  .sm
                  .gray600
                  .make(),
            ]),
          ],
          crossAlignment: CrossAxisAlignment.start,
        ).expand(),

        // Action buttons
        HStack([
          // View/Replace button
          GestureDetector(
            onTap: _openFileSelector,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FlutterIcons.eye_fea,
                color: AppColor.primaryColor,
                size: 20,
              ),
            ),
          ),

          SizedBox(width: 8),

          // Remove button
          GestureDetector(
            onTap: _removeFile,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FlutterIcons.trash_2_fea,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ]),
      ],
      alignment: MainAxisAlignment.start,
      crossAlignment: CrossAxisAlignment.center,
    )
        .p12()
        .box
        .roundedSM
        .color(Colors.green.shade50)
        .border(color: Colors.green.shade200)
        .make();
  }

  IconData _getFileIcon() {
    final extension = selectedPlatformFile?.extension?.toLowerCase();
    switch (extension) {
      case 'pdf':
        return FlutterIcons.file_pdf_faw5;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FlutterIcons.image_fea;
      case 'doc':
      case 'docx':
        return FlutterIcons.file_document_mco;
      default:
        return FlutterIcons.file_fea;
    }
  }

  void _openFileSelector() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.documentType.acceptedFormats,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final platformFile = result.files.first;

        // Check file size
        final fileSizeInMB = platformFile.size / (1024 * 1024);
        if (fileSizeInMB > widget.documentType.maxSizeMB) {
          ToastService.toastError(
            "File size exceeds ${widget.documentType.maxSizeMB}MB limit".tr(),
          );
          return;
        }

        setState(() {
          selectedFile = file;
          selectedPlatformFile = platformFile;
        });

        widget.onFileSelected(file, widget.documentType.id);
      }
    } catch (error) {
      ToastService.toastError("Error selecting file: $error".tr());
    }
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
      selectedPlatformFile = null;
    });
    widget.onFileRemoved?.call(widget.documentType.id);
  }
}

class UiSpacer {
  static Widget horizontalSpace({double space = 10}) {
    return SizedBox(width: space);
  }

  static Widget verticalSpace({double space = 10}) {
    return SizedBox(height: space);
  }
}

