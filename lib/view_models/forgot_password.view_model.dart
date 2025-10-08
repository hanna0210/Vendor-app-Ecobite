import 'package:fuodz/services/alert.service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/widgets/bottomsheets/account_verification_entry.dart';
import 'package:fuodz/widgets/bottomsheets/new_password_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sim_card_code/sim_card_code.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  AuthRequest _authRequest = AuthRequest();
  FirebaseAuth auth = FirebaseAuth.instance;
  late Country selectedCountry;
  String? accountPhoneNumber;
  //
  String? firebaseToken;
  String? firebaseVerificationId;

  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse("us");
  }

  void initialise() async {
    this.selectedCountry = Country.parse(
      await SimCardInfo.simCountryCode ?? "US",
    );
  }

  //
  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  //
  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  //verify on the server to see if there is an account associated with the supplied phone number
  processForgotPassword() async {
    accountPhoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      final apiResponse = await _authRequest.verifyPhoneAccount(
        accountPhoneNumber!,
      );
      setBusy(false);
      if (apiResponse.allGood) {
        //
        final phoneNumber = apiResponse.body["phone"];
        accountPhoneNumber = phoneNumber;
        if (!AppStrings.isCustomOtp) {
          processFirebaseForgotPassword(phoneNumber);
        } else {
          processCustomForgotPassword(phoneNumber);
        }
      } else {
        AlertService.error(
          title: "Forgot Password".tr(),
          text: apiResponse.message,
        );
      }
    }
  }

  //initiate the otp sending to provided phone
  processFirebaseForgotPassword(String phoneNumber) async {
    setBusy(true);

    //
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //
        UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );

        //fetch user id token
        firebaseToken = await userCredential.user?.getIdToken();
        firebaseVerificationId = credential.verificationId;

        //
        setBusy(false);
        showNewPasswordEntry();
      },
      verificationFailed: (FirebaseAuthException e) {
        setBusy(false);
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(msg: "Invalid Phone Number".tr());
        } else {
          viewContext.showToast(msg: e.message ?? "Failed".tr());
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        firebaseVerificationId = verificationId;
        setBusy(false);
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setBusy(false);
        //
        // firebaseVerificationId = verificationId;
        // showVerificationEntry();
        // setBusy(false);
      },
    );
  }

  //
  processCustomForgotPassword(String phoneNumber) async {
    setBusy(true);
    try {
      final apiResponse = await _authRequest.sendOTP(phoneNumber);
      String? instructions = (apiResponse.body as Map)["instructions"] ?? null;
      setBusy(false);
      showVerificationEntry(instructions);
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //show a bottomsheet to the user for verification code entry
  void showVerificationEntry([String? instructions]) {
    //
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder:
            (context) => AccountVerificationEntry(
              vm: this,
              onSubmit: (smsCode) {
                viewContext.pop();
                if (!AppStrings.isCustomOtp) {
                  verifyFirebaseOTP(smsCode);
                } else {
                  verifyCustomOTP(smsCode);
                }
              },
            ),
      ),
    );
    // showModalBottomSheet(
    //   context: viewContext,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return AccountVerificationEntry(
    //       vm: this,
    //       instruction: instructions,
    //       onSubmit: (smsCode) {
    //         //
    //         print("sms code ==> $smsCode");
    //         if (!AppStrings.isCustomOtp) {
    //           verifyFirebaseOTP(smsCode);
    //         } else {
    //           verifyCustomOTP(smsCode);
    //         }
    //         viewContext.pop();
    //       },
    //     );
    //   },
    // );
  }

  //verify the provided code with the firebase server
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await auth.signInWithCredential(
        phoneAuthCredential,
      );
      //
      firebaseToken = await userCredential.user?.getIdToken();
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  //verify the provided code with the custom sms gateway server
  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);

    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
      );
      firebaseToken = apiResponse.body["token"];
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }

  //show a bottomsheet to the user for verification code entry
  showNewPasswordEntry() {
    //
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder:
            (context) => NewPasswordEntry(
              vm: this,
              onSubmit: (password) {
                //
                finishChangeAccountPassword();
                viewContext.pop();
              },
            ),
      ),
    );
    // showModalBottomSheet(
    //   context: viewContext,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return NewPasswordEntry(
    //       vm: this,
    //       onSubmit: (password) {
    //         //
    //         finishChangeAccountPassword();
    //         viewContext.pop();
    //       },
    //     );
    //   },
    // );
  }

  //
  finishChangeAccountPassword() async {
    //

    setBusy(true);
    final apiResponse = await _authRequest.resetPasswordRequest(
      phone: accountPhoneNumber!,
      password: passwordTEC.text,
      firebaseToken: !AppStrings.isCustomOtp ? firebaseToken : null,
      customToken: AppStrings.isCustomOtp ? firebaseToken : null,
    );
    setBusy(false);

    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Forgot Password".tr(),
      text: apiResponse.message,
      onConfirm: () {
        Navigator.of(viewContext).popUntil((route) => route.isFirst);
      },
    );
  }
}
