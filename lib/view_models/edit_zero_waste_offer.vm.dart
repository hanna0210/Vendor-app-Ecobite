import 'dart:io';
import 'package:fuodz/services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/zero_waste_offer.dart';
import 'package:fuodz/requests/product.request.dart';
import 'package:fuodz/requests/zero_waste.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditZeroWasteOfferViewModel extends MyBaseViewModel {
  //
  EditZeroWasteOfferViewModel(BuildContext context, this.offer) {
    this.viewContext = context;
  }

  //
  ZeroWasteOffer offer;
  ZeroWasteRequest zeroWasteRequest = ZeroWasteRequest();
  ProductRequest productRequest = ProductRequest();
  List<Product> products = [];
  File? selectedPhoto;
  final formBuilderKey = GlobalKey<FormBuilderState>();

  void initialise() {
    fetchProducts();
  }

  //
  fetchProducts() async {
    setBusyForObject(products, true);

    try {
      products = await productRequest.getProducts();
      clearErrors();
    } catch (error) {
      print("Products Error ==> $error");
      setError(error);
    }

    setBusyForObject(products, false);
  }

  //
  onImageSelected(File? file) {
    selectedPhoto = file;
    notifyListeners();
  }

  //
  processUpdateOffer() async {
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      try {
        Map<String, dynamic> offerData = Map.from(
          formBuilderKey.currentState!.value,
        );

        final apiResponse = await zeroWasteRequest.updateOffer(
          offer,
          data: offerData,
          photo: selectedPhoto,
        );
        //
        //show dialog to present state
        await AlertService.dynamic(
          type: apiResponse.allGood ? AlertType.success : AlertType.error,
          title: "Update Zero Waste Offer".tr(),
          text: apiResponse.message,
        );

        //
        if (apiResponse.allGood) {
          Navigator.of(viewContext).pop(true);
        }
        clearErrors();
      } catch (error) {
        print("Update Zero Waste Offer Error ==> $error");
        setError(error);
      }

      setBusy(false);
    }
  }
}

