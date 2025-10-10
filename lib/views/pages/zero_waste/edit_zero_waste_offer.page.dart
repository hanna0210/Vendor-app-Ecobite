import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/zero_waste_offer.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/edit_zero_waste_offer.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/image_selector.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EditZeroWasteOfferPage extends StatelessWidget {
  const EditZeroWasteOfferPage(this.offer, {Key? key}) : super(key: key);

  final ZeroWasteOffer offer;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    );

    //
    return ViewModelBuilder<EditZeroWasteOfferViewModel>.reactive(
      viewModelBuilder: () => EditZeroWasteOfferViewModel(context, offer),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Edit Zero Waste Offer".tr(),
          body: SafeArea(
            top: true,
            bottom: false,
            child: FormBuilder(
              key: vm.formBuilderKey,
              child: VStack([
                //name
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(
                    labelText: 'Offer Name'.tr(),
                    border: inputBorder,
                  ),
                  initialValue: offer.name,
                  validator: CustomFormBuilderValidator.required,
                ),

                //description
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(
                    labelText: 'Description'.tr(),
                    border: inputBorder,
                  ),
                  initialValue: offer.description,
                  maxLines: 3,
                  validator: CustomFormBuilderValidator.required,
                ),

                //image
                ImageSelectorView(
                  onImageselected: vm.onImageSelected,
                  imageUrl: offer.photo ?? offer.product?.photo ?? "",
                ),

                //product selector (optional)
                if (vm.busy(vm.products))
                  Center(child: CircularProgressIndicator()).py12()
                else
                  FormBuilderDropdown(
                    name: 'product_id',
                    decoration: InputDecoration(
                      labelText: 'Link to Product (Optional)'.tr(),
                      border: inputBorder,
                    ),
                    initialValue: offer.productId,
                    items: vm.products
                        .map((product) => DropdownMenuItem(
                              value: product.id,
                              child: product.name.text.make(),
                            ))
                        .toList(),
                  ),

                //pricing
                HStack([
                  //original price
                  FormBuilderTextField(
                    name: 'original_price',
                    decoration: InputDecoration(
                      labelText: 'Original Price'.tr(),
                      border: inputBorder,
                    ),
                    initialValue: offer.originalPrice.toString(),
                    validator: (value) => CustomFormBuilderValidator.compose([
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
                    initialValue: offer.discountedPrice.toString(),
                    validator: (value) => CustomFormBuilderValidator.compose([
                      CustomFormBuilderValidator.required(value),
                      CustomFormBuilderValidator.numeric(value),
                    ]),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ).expand(),
                ]),

                //quantity
                FormBuilderTextField(
                  name: 'available_quantity',
                  decoration: InputDecoration(
                    labelText: 'Available Quantity'.tr(),
                    border: inputBorder,
                  ),
                  initialValue: offer.availableQuantity.toString(),
                  validator: (value) => CustomFormBuilderValidator.compose([
                    CustomFormBuilderValidator.required(value),
                    CustomFormBuilderValidator.numeric(value),
                  ]),
                  keyboardType: TextInputType.number,
                ),

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
                    initialValue: offer.pickupTimeStart,
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
                    initialValue: offer.pickupTimeEnd,
                    validator: CustomFormBuilderValidator.required,
                  ).expand(),
                ]),

                //expires at
                FormBuilderDateTimePicker(
                  name: 'expires_at',
                  decoration: InputDecoration(
                    labelText: 'Offer Expires At'.tr(),
                    border: inputBorder,
                  ),
                  inputType: InputType.both,
                  validator: CustomFormBuilderValidator.required,
                  initialValue: DateTime.tryParse(offer.expiresAt) ??
                      DateTime.now().add(Duration(days: 1)),
                ),

                //active status
                FormBuilderSwitch(
                  name: 'is_active',
                  title: "Active".tr().text.make(),
                  initialValue: offer.isActive == 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),

                //submit button
                CustomButton(
                  title: "Update Offer".tr(),
                  loading: vm.isBusy,
                  onPressed: vm.processUpdateOffer,
                  color: AppColor.primaryColor,
                ).h(Vx.dp48),
              ])
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

