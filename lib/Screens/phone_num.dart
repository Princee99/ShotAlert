import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shot_alert/Screens/otp.dart';
import 'package:shot_alert/services/logger_service.dart'; // Add this import

class Loginwithphone extends StatefulWidget {
  const Loginwithphone({super.key});

  @override
  State<Loginwithphone> createState() => _LoginwithphoneState();
}

class _LoginwithphoneState extends State<Loginwithphone> {
  bool isLoading = false;
  final auth = FirebaseAuth.instance;
  TextEditingController phonecontroller = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation("Previous Screen", "Phone Login Screen");
  }

  sendcode() async {
    Logger.logUserAction("Sending OTP to phone",
        {"phoneNumber": "+91${phonecontroller.text.trim()}"});

    if (phonecontroller.text.trim().isEmpty) {
      Logger.warning(Logger.USER, "Empty phone number");

      setState(() {
        errorMessage = "Please enter a phone number";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: '+91' + phonecontroller.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) {
          Logger.logAuth("Phone verification completed automatically");
        },
        verificationFailed: (FirebaseAuthException e) {
          Logger.error(
              Logger.AUTH, "Phone verification failed", e, {"code": e.code});

          setState(() {
            isLoading = false;
            errorMessage = "Verification failed: ${e.message}";
          });
        },
        codeSent: (String vid, int? token) {
          Logger.logAuth("OTP code sent successfully", {
            "verificationId": vid,
            "phoneNumber": '+91${phonecontroller.text.trim()}'
          });

          setState(() {
            isLoading = false;
          });

          Logger.logNavigation("Phone Login Screen", "OTP Screen");
          Get.to(() => Otppage(vid: vid));
        },
        codeAutoRetrievalTimeout: (vid) {
          Logger.warning(Logger.AUTH, "OTP auto retrieval timeout",
              {"verificationId": vid});

          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
      Logger.error(
          Logger.AUTH, "Unexpected error during phone verification", e);

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Phone Login',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              // ClipOval(
              //   child: Image.asset(
              //     'assets/Logo/logo.jpg',
              //     height: 120,
              //     width: 120,
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) {
              //       return Icon(
              //         Icons.security_rounded,
              //         size: 50,
              //         color: Colors.orange,
              //       );
              //     },
              //   ),
              // ),

              // SizedBox(height: 40),

              // Title and instructions
              Text(
                "Login with Phone",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              Text(
                "Enter your phone number to receive an OTP for verification",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Phone field with label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              SizedBox(height: 8),

              TextFormField(
                controller: phonecontroller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixText: "+91 ",
                  prefixStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),

              // Error message
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(height: 24),

              // Send OTP button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 190, 193, 196),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          "Send OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
