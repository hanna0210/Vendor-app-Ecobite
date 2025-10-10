import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/register.view_model.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/buttons/image_picker.view.dart';
import 'package:fuodz/widgets/forms/vendor_application_form.dart';
import 'package:fuodz/widgets/states/custom_loading.state.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/extensions/context.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    final inputDec = InputDecoration(border: OutlineInputBorder());

    //
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          showAppBar: true,
          elevation: 0,
          showLeadingAction: true,
          leading: Icon(
            FlutterIcons.close_ant,
            size: 24,
            color: Utils.textColorByColor(AppColor.primaryColor),
          ).p(Sizes.paddingSizeDefault).onInkTap(() {
            context.pop();
          }),
          body: FormBuilder(
            key: vm.formBuilderKey,
            child: VStack([
              //
              VStack([
                    //
                    VStack([
                          "Become a partner"
                              .tr()
                              .text
                              .xl3
                              .color(Utils.textColorByTheme())
                              .bold
                              .make(),
                          "Fill form below to continue"
                              .tr()
                              .text
                              .light
                              .color(Utils.textColorByTheme())
                              .make(),
                        ])
                        .p20()
                        .box
                        .color(AppColor.primaryColor)
                        .make()
                        .wFull(context),

                    //form
                    VStack([
                      //
                      "Business Information"
                          .tr()
                          .text
                          .underline
                          .xl
                          .semiBold
                          .make(),
                      UiSpacer.vSpace(30),
                      //
                      FormBuilderTextField(
                        name: "vendor_name",
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(labelText: "Name".tr()),
                      ),

                      16.heightBox,
                      HStack(
                        [
                          ImagePickerView(
                            title: "Logo".tr(),
                            image: vm.logo,
                            onPickPressed: vm.pickBusinessLogo,
                            height: context.percentHeight * 12,
                            onRemovePressed: () {
                              vm.logo = null;
                              vm.notifyListeners();
                            },
                          ).expand(),
                          ImagePickerView(
                            title: "Feature/Cover Image".tr(),
                            image: vm.featureImage,
                            onPickPressed: vm.pickBusinessFeatureImage,
                            height: context.percentHeight * 12,
                            onRemovePressed: () {
                              vm.featureImage = null;
                              vm.notifyListeners();
                            },
                          ).expand(),
                        ],
                        spacing: 15,
                        crossAlignment: CrossAxisAlignment.start,
                        alignment: MainAxisAlignment.start,
                      ),

                      //
                      20.heightBox,
                      //address
                      TypeAheadField<Address>(
                        controller: vm.addressTEC,
                        hideOnLoading: false,
                        hideWithKeyboard: false,
                        hideKeyboardOnDrag: true,
                        hideOnUnfocus: true,
                        debounceDuration: const Duration(seconds: 1),
                        builder: (context, controller, focusNode) {
                          return TextField(
                            autofocus: false,
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              hintText: "Address".tr(),
                              labelText: "Address".tr(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                        suggestionsCallback: (search) async {
                          if (search.isEmpty) return [];
                          return await vm.searchAddress(search);
                        },
                        itemBuilder: (context, Address? suggestion) {
                          if (suggestion == null) {
                            return Divider();
                          }
                          //
                          return VStack([
                            "${suggestion.addressLine ?? ''}".text.semiBold.lg
                                .make()
                                .px(12),
                            Divider(),
                          ]);
                        },
                        onSelected: vm.onAddressSelected,
                      ),

                      //
                      CustomLoadingStateView(
                        loading: vm.busy(vm.vendorTypes),
                        child: FormBuilderDropdown(
                          name: 'vendor_type_id',
                          decoration: inputDec.copyWith(
                            labelText: "Vendor Type".tr(),
                            hintText: 'Select Vendor Type'.tr(),
                          ),
                          initialValue: vm.selectedVendorTypeId,
                          onChanged: vm.changeSelectedVendorType,
                          validator: CustomFormBuilderValidator.required,
                          items:
                              vm.vendorTypes
                                  .map(
                                    (vendorType) => DropdownMenuItem(
                                      value: vendorType.id,
                                      child: '${vendorType.name}'.text.make(),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ).py20(),

                      FormBuilderTextField(
                        name: "vendor_email",
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) => CustomFormBuilderValidator.compose([
                              CustomFormBuilderValidator.required(value),
                              CustomFormBuilderValidator.email(value),
                            ]),
                        decoration: inputDec.copyWith(labelText: "Email".tr()),
                      ),

                      FormBuilderTextField(
                        name: "vendor_phone",
                        keyboardType: TextInputType.phone,
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(
                          labelText: "Phone".tr(),
                          prefixIcon: HStack([
                            //icon/flag
                            Flag.fromString(
                              vm.selectedVendorCountry?.countryCode ?? "us",
                              width: 20,
                              height: 20,
                            ),
                            UiSpacer.horizontalSpace(space: 5),
                            //text
                            ("+" + (vm.selectedVendorCountry?.phoneCode ?? "1"))
                                .text
                                .make(),
                          ]).px8().onInkTap(
                            () => vm.showCountryDialPicker(true),
                          ),
                        ),
                      ).py20(),

                      //business documents - Enhanced UI
                      UiSpacer.divider().py12(),
                      "Verification Documents"
                          .tr()
                          .text
                          .underline
                          .xl
                          .semiBold
                          .make(),
                      UiSpacer.vSpace(10),
                      "Please upload required documents to verify your business and identity"
                          .tr()
                          .text
                          .sm
                          .gray600
                          .make(),
                      UiSpacer.vSpace(20),
                      
                      // Use the enhanced vendor application form
                      VendorApplicationForm(
                        onDocumentsChanged: vm.onCategorizedDocumentsChanged,
                        initialDocuments: vm.categorizedDocuments,
                      ),

                      UiSpacer.divider().py12(),
                      "Personal Information"
                          .tr()
                          .text
                          .underline
                          .xl
                          .semiBold
                          .make(),
                      UiSpacer.vSpace(30),

                      FormBuilderTextField(
                        name: "name",
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(labelText: "Name".tr()),
                      ),

                      FormBuilderTextField(
                        name: "email",
                        keyboardType: TextInputType.emailAddress,
                        validator: CustomFormBuilderValidator.email,
                        decoration: inputDec.copyWith(labelText: "Email".tr()),
                      ).py20(),

                      FormBuilderTextField(
                        name: "phone",
                        keyboardType: TextInputType.phone,
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(
                          labelText: "Phone".tr(),
                          prefixIcon: HStack([
                            //icon/flag
                            Flag.fromString(
                              vm.selectedCountry?.countryCode ?? "us",
                              width: 20,
                              height: 20,
                            ),
                            UiSpacer.horizontalSpace(space: 5),
                            //text
                            ("+" + (vm.selectedCountry?.phoneCode ?? "1")).text
                                .make(),
                          ]).px8().onInkTap(vm.showCountryDialPicker),
                        ),
                      ),

                      FormBuilderTextField(
                        name: "password",
                        obscureText: vm.hidePassword,
                        validator: CustomFormBuilderValidator.required,
                        decoration: inputDec.copyWith(
                          labelText: "Password".tr(),
                          suffixIcon: Icon(
                            vm.hidePassword
                                ? FlutterIcons.ios_eye_ion
                                : FlutterIcons.ios_eye_off_ion,
                          ).onInkTap(() {
                            vm.hidePassword = !vm.hidePassword;
                            vm.notifyListeners();
                          }),
                        ),
                      ).py20(),

                      FormBuilderCheckbox(
                        name: "agreed",
                        title:
                            "I agree with"
                                .tr()
                                .richText
                                .semiBold
                                .withTextSpanChildren([
                                  " ".textSpan.make(),
                                  "terms and conditions"
                                      .tr()
                                      .textSpan
                                      .underline
                                      .semiBold
                                      .tap(() {
                                        vm.openWebpageLink(Api.terms);
                                      })
                                      .color(AppColor.primaryColor)
                                      .make(),
                                ])
                                .make(),
                        validator:
                            (value) => CustomFormBuilderValidator.required(
                              value,
                              errorTitle:
                                  "Please confirm you have accepted our terms and conditions"
                                      .tr(),
                            ),
                      ),
                      //
                      CustomButton(
                        title: "Sign Up".tr(),
                        loading: vm.isBusy,
                        onPressed: vm.processLogin,
                      ).centered().py20(),
                    ]).p20(),
                  ])
                  .wFull(context)
                  .scrollVertical()
                  .box
                  .color(context.cardColor)
                  .make()
                  .pOnly(bottom: context.mq.viewInsets.bottom)
                  .expand(),
            ]),
          ),
        );
      },
    );
  }
}
