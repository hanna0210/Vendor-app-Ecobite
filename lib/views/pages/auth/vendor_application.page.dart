import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/vendor_document.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/vendor_application.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/vendor_document_upload.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class VendorApplicationPage extends StatelessWidget {
  const VendorApplicationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorApplicationViewModel>.reactive(
      viewModelBuilder: () => VendorApplicationViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Vendor Application".tr(),
          isLoading: vm.isBusy,
          body: VStack(
            [
              // Header Section
              _buildHeaderSection(context, vm),

              UiSpacer.vSpace(24),

              // Progress Indicator
              _buildProgressIndicator(context, vm),

              UiSpacer.vSpace(24),

              // Instructions
              _buildInstructionsSection(context),

              UiSpacer.vSpace(24),

              // Required Documents Section
              _buildSectionTitle(context, "Required Documents".tr(), true),
              UiSpacer.vSpace(12),
              ...VendorDocumentType.requiredDocuments.map(
                (docType) => VendorDocumentUploadView(
                  documentType: docType,
                  onDocumentSelected: (document) =>
                      vm.onDocumentUpdated(docType, document),
                  initialDocument: vm.documents[docType],
                  isRequired: true,
                ),
              ),

              UiSpacer.vSpace(24),

              // Optional Documents Section
              _buildSectionTitle(context, "Optional Documents".tr(), false),
              UiSpacer.vSpace(12),
              ...VendorDocumentType.optionalDocuments.map(
                (docType) => VendorDocumentUploadView(
                  documentType: docType,
                  onDocumentSelected: (document) =>
                      vm.onDocumentUpdated(docType, document),
                  initialDocument: vm.documents[docType],
                  isRequired: false,
                ),
              ),

              UiSpacer.vSpace(24),

              // Submit Button
              CustomButton(
                title: "Submit Application".tr(),
                loading: vm.isBusy,
                icon: FlutterIcons.check_circle_fea,
                onPressed: vm.canSubmit ? vm.submitApplication : null,
              ).wFull(context),

              UiSpacer.vSpace(40),
            ],
          )
              .p20()
              .scrollVertical()
              .box
              .color(context.theme.colorScheme.surface)
              .make(),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, VendorApplicationViewModel vm) {
    return VStack(
      [
        Icon(
          FlutterIcons.file_text_fea,
          size: 64,
          color: AppColor.primaryColor,
        ),
        UiSpacer.vSpace(16),
        "Complete Your Application"
            .tr()
            .text
            .xl2
            .semiBold
            .center
            .color(Utils.textColorByTheme())
            .make(),
        UiSpacer.vSpace(8),
        "Upload your verification documents to become a verified vendor"
            .tr()
            .text
            .center
            .gray600
            .make(),
      ],
      crossAlignment: CrossAxisAlignment.center,
    )
        .p20()
        .box
        .roundedSM
        .color(AppColor.primaryColor.withOpacity(0.1))
        .make()
        .wFull(context);
  }

  Widget _buildProgressIndicator(
      BuildContext context, VendorApplicationViewModel vm) {
    final progress = vm.completionProgress;
    final percentage = (progress * 100).toInt();

    return VStack(
      [
        HStack(
          [
            "Application Progress".tr().text.semiBold.make().expand(),
            "$percentage%".text.semiBold.color(AppColor.primaryColor).make(),
          ],
        ),
        UiSpacer.vSpace(8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : AppColor.primaryColor,
          ),
          minHeight: 8,
        ).box.roundedSM.clip(Clip.antiAlias).make(),
        UiSpacer.vSpace(4),
        "${vm.uploadedRequiredDocuments} of ${VendorDocumentType.requiredDocuments.length} required documents uploaded"
            .tr()
            .text
            .sm
            .gray600
            .make(),
      ],
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            Icon(FlutterIcons.info_fea, color: Colors.blue, size: 20),
            UiSpacer.hSpace(8),
            "Important Instructions".tr().text.semiBold.make(),
          ],
        ),
        UiSpacer.vSpace(12),
        _buildInstructionItem(
          "1. Ensure all documents are clear and readable".tr(),
        ),
        _buildInstructionItem(
          "2. Upload valid, unexpired documents".tr(),
        ),
        _buildInstructionItem(
          "3. Supported formats: PDF, JPG, PNG (Max 10MB each)".tr(),
        ),
        _buildInstructionItem(
          "4. All required documents must be uploaded before submission".tr(),
        ),
      ],
    )
        .p16()
        .box
        .roundedSM
        .border(color: Colors.blue.shade200)
        .color(Colors.blue.shade50)
        .make();
  }

  Widget _buildInstructionItem(String text) {
    return HStack(
      [
        Icon(FlutterIcons.check_fea, color: Colors.blue, size: 14),
        UiSpacer.hSpace(8),
        text.text.sm.make().expand(),
      ],
      crossAlignment: CrossAxisAlignment.start,
    ).py4();
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isRequired) {
    return HStack(
      [
        title.text.xl.semiBold.color(Utils.textColorByTheme()).make(),
        if (isRequired) ...[
          UiSpacer.hSpace(8),
          "*".text.red500.xl.make(),
        ],
      ],
    );
  }
}
