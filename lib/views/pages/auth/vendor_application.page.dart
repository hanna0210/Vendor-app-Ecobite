import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/vendor_application.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/forms/vendor_application_form.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorApplicationPage extends StatelessWidget {
  const VendorApplicationPage({
    Key? key,
    this.onDocumentsSubmitted,
    this.isStandalone = true,
  }) : super(key: key);

  final Function(Map<String, File> documents)? onDocumentsSubmitted;
  final bool isStandalone;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorApplicationViewModel>.reactive(
      viewModelBuilder: () => VendorApplicationViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: isStandalone,
          showLeadingAction: isStandalone,
          title: "Vendor Application".tr(),
          isLoading: vm.isBusy,
          body: VStack(
            [
              // Progress indicator at the top
              if (isStandalone) _buildProgressIndicator(vm),

              // Main content
              VStack(
                [
                  // Application form with document uploads
                  VendorApplicationForm(
                    onDocumentsChanged: vm.onDocumentsChanged,
                    initialDocuments: vm.uploadedDocuments,
                  ),

                  32.heightBox,

                  // Action buttons
                  if (isStandalone) _buildActionButtons(context, vm),
                ],
              )
                  .p20()
                  .scrollVertical()
                  .expand(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(VendorApplicationViewModel vm) {
    return VStack(
      [
        HStack(
          [
            _buildStepIndicator(1, "Business Info", true, true),
            Expanded(
              child: Container(
                height: 2,
                color: AppColor.primaryColor,
              ),
            ),
            _buildStepIndicator(2, "Documents", true, false),
            Expanded(
              child: Container(
                height: 2,
                color: Colors.grey.shade300,
              ),
            ),
            _buildStepIndicator(3, "Review", false, false),
          ],
        ),
      ],
    )
        .p20()
        .box
        .white
        .shadowSm
        .make();
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    bool isCompleted,
    bool isActive,
  ) {
    return VStack(
      [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? AppColor.primaryColor
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isCompleted && !isActive
              ? Icon(Icons.check, color: Colors.white, size: 20)
              : "$step".text.white.bold.make().centered(),
        ),
        4.heightBox,
        label.tr().text.xs.center.make().w(60),
      ],
      crossAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    VendorApplicationViewModel vm,
  ) {
    return VStack(
      [
        CustomButton(
          title: "Submit Application".tr(),
          loading: vm.isBusy,
          onPressed: vm.canSubmit
              ? () {
                  if (onDocumentsSubmitted != null) {
                    onDocumentsSubmitted!(vm.uploadedDocuments);
                  } else {
                    vm.submitApplication();
                  }
                }
              : null,
        ),
        12.heightBox,
        CustomButton(
          title: "Save as Draft".tr(),
          color: Colors.grey.shade600,
          onPressed: vm.saveDraft,
        ).centered(),
        16.heightBox,
        "By submitting this application, you agree to our Terms of Service and Privacy Policy"
            .tr()
            .text
            .xs
            .gray600
            .center
            .make(),
      ],
    );
  }
}

