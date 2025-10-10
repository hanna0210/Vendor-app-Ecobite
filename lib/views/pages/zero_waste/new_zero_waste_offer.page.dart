import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/new_zero_waste_offer.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/image_selector.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NewZeroWasteOfferPage extends StatelessWidget {
  const NewZeroWasteOfferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    );

    //
    return ViewModelBuilder<NewZeroWasteOfferViewModel>.reactive(
      viewModelBuilder: () => NewZeroWasteOfferViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "New Zero Waste Offer".tr(),
          body: SafeArea(
            top: true,
            bottom: false,
            child: FormBuilder(
              key: vm.formBuilderKey,
              child: VStack(
                [
                  //Header Section
                  VStack([
                    "Create Zero Waste Offer".tr().text.xl.semiBold.make(),
                    "Help reduce food waste and earn from surplus items"
                        .tr()
                        .text
                        .sm
                        .gray500
                        .make(),
                  ], spacing: 4),

                  20.heightBox,

                  //name
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: 'Offer Name'.tr(),
                      hintText: 'e.g., Surplus Bread Bundle'.tr(),
                      border: inputBorder,
                    ),
                    validator: CustomFormBuilderValidator.required,
                  ),

                  16.heightBox,

                  //description
                  FormBuilderTextField(
                    name: 'description',
                    decoration: InputDecoration(
                      labelText: 'Description'.tr(),
                      hintText:
                          'Describe what customers can expect to receive'.tr(),
                      border: inputBorder,
                    ),
                    maxLines: 3,
                    validator: CustomFormBuilderValidator.required,
                  ),

                  20.heightBox,

                  //image
                  VStack([
                    "Offer Photo (Optional)".tr().text.sm.semiBold.make(),
                    8.heightBox,
                    ImageSelectorView(
                      onImageselected: vm.onImageSelected,
                      imageUrl: "",
                    ),
                  ]),

                  20.heightBox,

                  //product selector (optional)
                  if (vm.busy(vm.products))
                    Center(child: CircularProgressIndicator()).py20()
                  else
                    FormBuilderDropdown(
                      name: 'product_id',
                      decoration: InputDecoration(
                        labelText: 'Link to Product (Optional)'.tr(),
                        border: inputBorder,
                        helperText: 'Connect this offer to an existing product'
                            .tr(),
                      ),
                      items: vm.products
                          .map((product) => DropdownMenuItem(
                                value: product.id,
                                child: product.name.text.make(),
                              ))
                          .toList(),
                    ),

                  24.heightBox,

                  //Pricing section header
                  "Pricing".tr().text.lg.semiBold.make(),
                  8.heightBox,

                  //pricing
                  HStack([
                    //original price
                    FormBuilderTextField(
                      name: 'original_price',
                      decoration: InputDecoration(
                        labelText: 'Original Price'.tr(),
                        border: inputBorder,
                      ),
                      validator: (value) =>
                          CustomFormBuilderValidator.compose([
                        CustomFormBuilderValidator.required(value),
                        CustomFormBuilderValidator.numeric(value),
                      ]),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ).expand(),

                    UiSpacer.horizontalSpace(),

                    //discounted price
                    FormBuilderTextField(
                      name: 'discounted_price',
                      decoration: InputDecoration(
                        labelText: 'Discounted Price'.tr(),
                        border: inputBorder,
                      ),
                      validator: (value) =>
                          CustomFormBuilderValidator.compose([
                        CustomFormBuilderValidator.required(value),
                        CustomFormBuilderValidator.numeric(value),
                      ]),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ).expand(),
                  ]),

                  16.heightBox,

                  //quantity
                  FormBuilderTextField(
                    name: 'available_quantity',
                    decoration: InputDecoration(
                      labelText: 'Available Quantity'.tr(),
                      hintText: 'How many units available?'.tr(),
                      border: inputBorder,
                    ),
                    validator: (value) => CustomFormBuilderValidator.compose([
                      CustomFormBuilderValidator.required(value),
                      CustomFormBuilderValidator.numeric(value),
                    ]),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                  ),

                  24.heightBox,

                  //Availability section header
                  "Availability & Timing".tr().text.lg.semiBold.make(),
                  8.heightBox,

                  //pickup time
                  HStack([
                    //start time
                    FormBuilderTextField(
                      name: 'pickup_time_start',
                      decoration: InputDecoration(
                        labelText: 'Pickup Start Time'.tr(),
                        hintText: '18:00',
                        border: inputBorder,
                      ),
                      validator: CustomFormBuilderValidator.required,
                    ).expand(),

                    UiSpacer.horizontalSpace(),

                    //end time
                    FormBuilderTextField(
                      name: 'pickup_time_end',
                      decoration: InputDecoration(
                        labelText: 'Pickup End Time'.tr(),
                        hintText: '21:00',
                        border: inputBorder,
                      ),
                      validator: CustomFormBuilderValidator.required,
                    ).expand(),
                  ]),

                  16.heightBox,

                  //expires at
                  FormBuilderDateTimePicker(
                    name: 'expires_at',
                    decoration: InputDecoration(
                      labelText: 'Offer Expires At'.tr(),
                      border: inputBorder,
                      helperText: 'When should this offer end?'.tr(),
                    ),
                    inputType: InputType.both,
                    validator: CustomFormBuilderValidator.required,
                    initialValue: DateTime.now().add(Duration(days: 1)),
                  ),

                  20.heightBox,

                  //active status
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FormBuilderSwitch(
                      name: 'is_active',
                      title: "Activate Offer Immediately".tr().text.make(),
                      initialValue: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  32.heightBox,

                  //submit button
                  CustomButton(
                    title: "Create Offer".tr(),
                    loading: vm.isBusy,
                    onPressed: vm.processNewOffer,
                    color: AppColor.primaryColor,
                  ).h(Vx.dp48),

                  20.heightBox,
                ],
                crossAlignment: CrossAxisAlignment.start,
              )
                  .p20()
                  .scrollVertical()
                  .expand(),
            ),
          ),
        );
      },
    );
  }
}

