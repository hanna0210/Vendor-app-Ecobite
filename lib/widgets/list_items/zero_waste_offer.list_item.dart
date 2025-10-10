import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/zero_waste_offer.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ZeroWasteOfferListItem extends StatelessWidget {
  //
  const ZeroWasteOfferListItem(
    this.offer, {
    this.isLoading = false,
    required this.onEditPressed,
    required this.onToggleStatusPressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  //
  final ZeroWasteOffer offer;
  final bool isLoading;
  final Function(ZeroWasteOffer) onEditPressed;
  final Function(ZeroWasteOffer) onToggleStatusPressed;
  final Function(ZeroWasteOffer) onDeletePressed;
  
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;

    //
    return VStack([
      HStack([
        //
        CustomImage(
          imageUrl: offer.photo ?? offer.product?.photo ?? "",
          width: context.percentWidth * 18,
          height: context.percentWidth * 14,
        ).box.clip(Clip.antiAlias).roundedSM.make(),

        //Details
        VStack([
          //name
          offer.name.text.scale(0.95).semiBold.maxLines(1).ellipsis.make(),
          //description
          offer.description.text.xs.maxLines(1).ellipsis.make(),
          //
          HStack([
            //original price
            "$currencySymbol ${offer.originalPrice}"
                .currencyFormat()
                .text
                .lineThrough
                .xs
                .make(),

            //discounted price
            "$currencySymbol ${offer.discountedPrice}"
                .currencyFormat()
                .text
                .scale(0.90)
                .semiBold
                .green500
                .make(),

            //discount percentage
            "${offer.discountPercentage.toStringAsFixed(0)}% off"
                .text
                .xs
                .color(Colors.orange)
                .make(),
          ], spacing: 10),

          //quantity and time
          HStack([
            //quantity
            "Qty: ${offer.availableQuantity}".text.xs.gray500.make(),
            "•".text.gray500.make(),
            //pickup time
            "${offer.pickupTimeStart} - ${offer.pickupTimeEnd}"
                .text
                .xs
                .gray500
                .make(),
          ], spacing: 5),
        ], spacing: 2).expand(),

        //actions
        Container(
          constraints: BoxConstraints(maxWidth: context.percentWidth * 24),
          child: Wrap(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                color: context.primaryColor,
                onPressed: () => onEditPressed(offer),
                icon: Icon(FlutterIcons.edit_2_fea),
              ),

              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: EdgeInsets.zero,
                onPressed: () => onDeletePressed(offer),
                color: Colors.red,
                icon: Icon(FlutterIcons.trash_fea),
              ),
            ],
            spacing: 0,
          ),
        ),
        //
      ], spacing: 15),

      //Status badge
      HStack([
        //active/inactive status
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: offer.isActive == 1 ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: (offer.isActive == 1 ? "Active" : "Inactive")
              .tr()
              .text
              .xs
              .white
              .make(),
        ),
        //expired status
        if (offer.isExpired)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: "Expired".tr().text.xs.white.make(),
          ),
        //availability status
        if (!offer.isAvailable && !offer.isExpired)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: "Unavailable".tr().text.xs.white.make(),
          ),
      ], spacing: 8).pOnly(top: 8),
    ])
        .p12()
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusDefault)
        .make();
  }
}

