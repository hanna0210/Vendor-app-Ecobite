import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/zero_waste_offers.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:fuodz/widgets/list_items/zero_waste_offer.list_item.dart';
import 'package:fuodz/widgets/states/error.state.dart';
import 'package:fuodz/widgets/states/empty.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ZeroWasteOffersPage extends StatefulWidget {
  const ZeroWasteOffersPage({Key? key}) : super(key: key);

  @override
  _ZeroWasteOffersPageState createState() => _ZeroWasteOffersPageState();
}

class _ZeroWasteOffersPageState extends State<ZeroWasteOffersPage>
    with AutomaticKeepAliveClientMixin<ZeroWasteOffersPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<ZeroWasteOffersViewModel>.reactive(
        viewModelBuilder: () => ZeroWasteOffersViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            fab: FloatingActionButton(
              backgroundColor: AppColor.primaryColor,
              onPressed: vm.newOffer,
              child: Icon(
                FlutterIcons.plus_faw,
                color: Colors.white,
              ),
            ),
            body: VStack(
              [
                //Header
                VStack([
                  "Zero Waste Offers".tr().text.xl2.semiBold.make(),
                  "Reduce food waste by offering surplus items at discounted prices"
                      .tr()
                      .text
                      .sm
                      .gray500
                      .make(),
                ]).p20(),
                
                //search bar
                CustomTextFormField(
                  hintText: "Search offers".tr(),
                  onFieldSubmitted: vm.offerSearch,
                ).pOnly(
                  top: Vx.dp4,
                  bottom: Vx.dp12,
                ),

                //
                CustomListView(
                  canRefresh: true,
                  canPullUp: true,
                  refreshController: vm.refreshController,
                  onRefresh: vm.fetchOffers,
                  onLoading: () => vm.fetchOffers(initialLoading: false),
                  isLoading: vm.isBusy,
                  dataSet: vm.offers,
                  hasError: vm.hasError,
                  errorWidget: LoadingError(
                    onrefresh: vm.fetchOffers,
                  ),
                  //
                  emptyWidget: EmptyState(
                    title: "No Zero Waste Offers".tr(),
                    description:
                        "You haven't created any zero waste offers yet. Tap the + button to create your first offer."
                            .tr(),
                  ),
                  itemBuilder: (context, index) {
                    //
                    final offer = vm.offers[index];
                    return ZeroWasteOfferListItem(
                      offer,
                      isLoading: vm.busy(offer.id),
                      onEditPressed: vm.editOffer,
                      onToggleStatusPressed: vm.changeOfferStatus,
                      onDeletePressed: vm.deleteOffer,
                    );
                  },
                  separatorBuilder: (p0, p1) => 12.heightBox,
                ).expand(),
              ],
            ).px20(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

