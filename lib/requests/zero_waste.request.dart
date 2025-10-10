import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/zero_waste_offer.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/http.service.dart';
import 'package:fuodz/utils/utils.dart';

class ZeroWasteRequest extends HttpService {
  //
  Future<List<ZeroWasteOffer>> getOffers({
    String? keyword,
    int page = 1,
  }) async {
    final apiResult = await get(
      Api.zeroWasteOffers,
      queryParameters: {
        "keyword": keyword,
        "type": "vendor",
        "page": page,
        "vendor_id": AuthServices.currentVendor?.id,
      },
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<ZeroWasteOffer> offers = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          final offer = ZeroWasteOffer.fromJson(jsonObject);
          offers.add(offer);
        } catch (error) {
          print("Error parsing zero waste offer ==> $error");
        }
      });
      return offers;
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<ZeroWasteOffer> getOfferDetails(int offerId) async {
    final apiResult = await get(
      Api.zeroWasteOffers + "/$offerId",
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return ZeroWasteOffer.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message;
    }
  }

  Future<ApiResponse> createOffer(
    Map<String, dynamic> value, {
    File? photo,
  }) async {
    //
    final postBody = {
      ...value,
      "vendor_id": AuthServices.currentVendor?.id,
    };

    FormData formData = FormData.fromMap(postBody);
    if (photo != null) {
      File? mFile = await Utils.compressFile(
        file: photo,
        quality: 60,
      );
      if (mFile != null) {
        formData.files.add(
          MapEntry("photo", await MultipartFile.fromFile(mFile.path)),
        );
      }
    }

    final apiResult = await postWithFiles(
      Api.zeroWasteOffers,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> deleteOffer(
    ZeroWasteOffer offer,
  ) async {
    final apiResult = await delete(
      Api.zeroWasteOffers + "/${offer.id}",
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateOffer(
    ZeroWasteOffer offer, {
    Map<String, dynamic>? data,
    File? photo,
  }) async {
    //
    final postBody = {
      "_method": "PUT",
      ...(data == null ? offer.toJson() : data),
      "vendor_id": AuthServices.currentVendor?.id,
    };
    FormData formData = FormData.fromMap(
      postBody,
      ListFormat.multiCompatible,
    );

    if (photo != null) {
      File? mFile = await Utils.compressFile(
        file: photo,
        quality: 60,
      );
      if (mFile != null) {
        formData.files.add(
          MapEntry("photo", await MultipartFile.fromFile(mFile.path)),
        );
      }
    }

    final apiResult = await postWithFiles(
      Api.zeroWasteOffers + "/${offer.id}",
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }
}

