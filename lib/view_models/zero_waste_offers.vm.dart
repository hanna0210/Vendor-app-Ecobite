import 'package:fuodz/services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/zero_waste_offer.dart';
import 'package:fuodz/requests/zero_waste.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/zero_waste/edit_zero_waste_offer.page.dart';
import 'package:fuodz/views/pages/zero_waste/new_zero_waste_offer.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ZeroWasteOffersViewModel extends MyBaseViewModel {
  //
  ZeroWasteOffersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  ZeroWasteRequest zeroWasteRequest = ZeroWasteRequest();
  List<ZeroWasteOffer> offers = [];
  //
  int queryPage = 1;
  String keyword = "";
  RefreshController refreshController = RefreshController();

  void initialise() {
    fetchOffers();
  }

  //
  fetchOffers({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOffers = await zeroWasteRequest.getOffers(
        page: queryPage,
        keyword: keyword,
      );
      if (!initialLoading) {
        offers.addAll(mOffers);
        refreshController.loadComplete();
      } else {
        offers = mOffers;
      }
      clearErrors();
    } catch (error) {
      print("Zero Waste Offers Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  offerSearch(String value) {
    keyword = value;
    fetchOffers();
  }

  void newOffer() async {
    final result = await viewContext.push(
      (context) => NewZeroWasteOfferPage(),
    );
    //
    if (result != null) {
      fetchOffers();
    }
  }

  editOffer(ZeroWasteOffer offer) async {
    //
    final result = await viewContext.push(
      (context) => EditZeroWasteOfferPage(offer),
    );
    if (result != null) {
      fetchOffers();
    }
  }

  changeOfferStatus(ZeroWasteOffer offer) {
    //
    AlertService.confirm(
      title: "Status Update".tr(),
      text: "Are you sure you want to".tr() +
          " ${(offer.isActive != 1 ? "Activate" : "Deactivate").tr()} ${offer.name}?",
      onConfirm: () {
        processStatusUpdate(offer);
      },
    );
  }

  processStatusUpdate(ZeroWasteOffer offer) async {
    //
    offer.isActive = offer.isActive == 1 ? 0 : 1;
    //
    setBusyForObject(offer.id, true);
    try {
      final apiResponse = await zeroWasteRequest.updateOffer(
        offer,
      );
      //
      if (apiResponse.allGood) {
        fetchOffers();
      }
      //show dialog to present state
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Status Update".tr(),
        text: apiResponse.message,
      );
      clearErrors();
    } catch (error) {
      print("Update Status Zero Waste Offer Error ==> $error");
      setError(error);
    }
    setBusyForObject(offer.id, false);
  }

  //
  deleteOffer(ZeroWasteOffer offer) {
    //
    AlertService.confirm(
      title: "Delete Offer".tr(),
      text: "Are you sure you want to delete".tr() + " ${offer.name}?",
      onConfirm: () {
        processDeletion(offer);
      },
    );
  }

  processDeletion(ZeroWasteOffer offer) async {
    //
    setBusyForObject(offer.id, true);
    try {
      final apiResponse = await zeroWasteRequest.deleteOffer(
        offer,
      );
      //
      if (apiResponse.allGood) {
        offers.removeWhere((element) => element.id == offer.id);
      }
      //show dialog to present state
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Delete Offer".tr(),
        text: apiResponse.message,
      );
      clearErrors();
    } catch (error) {
      print("Delete Zero Waste Offer Error ==> $error");
      setError(error);
    }
    setBusyForObject(offer.id, false);
  }
}

