import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shot_alert/wrapper.dart';
import 'package:pinput/pinput.dart';
import 'package:shot_alert/controllers/otp_controller.dart';
import 'package:shot_alert/services/logger_service.dart'; // Add this import

class Otppage extends StatefulWidget {
  final String vid;

  const Otppage({super.key, required this.vid});

  @override
  State<Otppage> createState() => _OtppageState();
}

class _OtppageState extends State<Otppage> {
  final CodeController codec = Get.put(CodeController());

  @override
  void initState() {
    super.initState();
    Logger.logNavigation("Phone Number Screen", "OTP Screen");
    Logger.debug(
        Logger.AUTH, "OTP verification ID", {"verificationId": widget.vid});
  }

  signin() async {
    Logger.logUserAction(
        "Verifying OTP code", {"codeLength": codec.code.value.length});

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.vid,
      smsCode: codec.code.value,
    );

    try {
      UserCredential userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Logger.logAuth("Phone authentication successful", {
        "uid": userCred.user?.uid,
        "phoneNumber": userCred.user?.phoneNumber
      });

      Get.offAll(Wrapper());
    } on FirebaseAuthException catch (e) {
      Logger.error(Logger.AUTH, "OTP verification failed", e, {"code": e.code});

      Get.snackbar("Error occured", e.code);
    } catch (e) {
      Logger.error(Logger.AUTH, "Unexpected error during OTP verification", e);

      Get.snackbar("Error occured", e.toString());
    }
  }

  var code = '';

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Enter OTP"),
            SizedBox(height: 25),
            textcode(),
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                signin();
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.orange[400],
                ),

                child: Center(
                  child: Text(
                    "Verify & proceed",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                // width: 275,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textcode() {
    return Center(
      child: Pinput(
        length: 6,
        onChanged: (value) {
          codec.code.value = value;
        },
      ),
    );
  }
}
